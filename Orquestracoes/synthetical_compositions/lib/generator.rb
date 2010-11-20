#gems
Dir["/Users/ticolucci/.rvm/gems/ruby-1.9.2-p0/gems/*"].each {|gem_dir| $: << "#{gem_dir}/lib/"} #hardcoded patch for rvm...
require 'rubygems'
require 'AWS'

#builtins
require 'thread'
require 'fileutils'
include FileUtils

#libs
require './lib/orchestration'
require './lib/graph'
require './lib/petals'
require './lib/color_text'

#confs
require './conf/amazon_keys'
#require './conf/ids'

class Generator
  def initialize number_of_children, depth
    puts "Generating graph of relations..."
    @graph = Graph.new depth, number_of_children
    puts "done\n\n\n"
    @nodes_state = {}
    @lock_states = Mutex.new
  end

  def instantiate_compositions print_states
    ids = create_vms @graph.size #  IDS
    distribute_ids ids
    
    printer = print_states ? start_printer : Thread.new
    collect_dns_names
    wait_ssh
    set_date    
    set_up_topology_and_properties

    @graph.each_node_parallel do |node|
      prepare_node_for_message node
    end

    root_node = @graph.root
    root_host = root_node.info[:public_dns]
    root_port = 8084
    root_service_path = "/petals/services/#{root_node}Service#{root_node.id}"
    puts "\n"*3
    puts "Nodes description:"
    @graph.each_node do |node|
      puts "#{node.is_root? ? 'Root' : node}:\nhttp://#{node.info[:public_dns]}:8084/petals/services/#{node}Service#{node.id}\nid: #{node.id}"
    end
    puts "\n"*3
    Thread.kill printer
    return root_host, root_port, root_service_path, root_node.id
  end

  def terminate_compositions
    puts "Terminating instances..."
    ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY_ID, :secret_access_key => SECRET_ACCESS_KEY)
    @graph.each_node do |node|
      ec2.terminate_instances :instance_id => node.info[:instance_id]
    end
    rm_f "resources/topology.xml"
    rm_f "resources/server.properties*"
    rm_f "resources/node*"
    rm_f "resources/leaf*"
    puts "done\n\n\n"
  end

  private
  def start_printer
    Thread.new do
      loop {
        @lock_states.synchronize do
          puts "\n"*80

          header = "#   State \\ Instance     " + @nodes_state.keys.join("    ") + "     #"
          puts "\n"*5
          puts "\t\t" + ("#" * header.size)
          puts "\t\t" + header
          puts "\t\t#       dns set           " + (@nodes_state.keys.collect{|k| ok_or_not_ok k, :dns }).join("    ") + "    #"
          puts "\t\t#      ssh ready          " + (@nodes_state.keys.collect{|k| ok_or_not_ok k, :ssh }).join("    ") + "    #"
          puts "\t\t#     topology sent       " + (@nodes_state.keys.collect{|k| ok_or_not_ok k, :topology }).join("    ") + "    #"
          puts "\t\t#     petals state        " + (@nodes_state.keys.collect{|k| status_of_petals @nodes_state[k][:petals], k.size }).join("    ") + "    #"
          puts "\t\t#  orchestration running  " + (@nodes_state.keys.collect{|k| ok_or_not_ok k, :orchestration }).join("    ") + "    #"
          puts "\t\t" + ("#" * header.size)
          puts "\n" *10
          @nodes_state.keys.each do |k|
            dns = @nodes_state[k][:dns]
            if dns
              puts "\t\t#{k} -> #{dns}" 
            else
              node = @nodes_state[k][:node]
              puts "\t\t#{node} => #{node.inspect}"
            end
          end
          puts "\n" *10
        end        
        sleep 1
      }
    end
  end

  def ok_or_not_ok key, field
    s,l = (@nodes_state[key][field] ? [ColorText.green("Yes"),3] : [ColorText.red("No"),2])
    s.center(s.size + key.size - l) 
  end
  
  def status_of_petals petals, size
    colorful, l = case petals
    when "Stopped"
      [ColorText.red("Stopped"), 7]
    when "Running"
      [ColorText.yellow("Running"), 7]
    when "Ready"
      [ColorText.green("Ready"), 5]
    end
    colorful.center(colorful.size + size - l)
  end




  def create_vms size
    begin
      puts "Creating amazon virtual machines..."
      ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY_ID, :secret_access_key => SECRET_ACCESS_KEY)

      response = ec2.run_instances :image_id => AMI_ID, :min_count => size, :max_count => size, :key_name => KEY_NAME, :instance_type => "t1.micro", :security_group => "quick-start-1"
      ids = collect_instances_id response
      puts "done\n\n\n"
      ids
    rescue AWS::InstanceLimitExceeded => e
      e.message =~ /allows for (\d+) .* at least (\d+)/
      quota = $1
      requested = $2
      puts "\t[ERROR]I'm sorry,  but your quota in AWS is #{quota} instances. To build this #{@composition_clazz}, I'll need at least #{requested} instances"
      exit -1
    end
  end

  def distribute_ids ids
    available_ids = ids.dup
    @graph.each_node do |node|
      id = available_ids.shift
      node.info = {:instance_id => id}
      @lock_states.synchronize do
        @nodes_state[id] = {:dns => false, :topology => false, :petals => 'Stopped', :orchestration => false, :node => node, :ssh => false}
      end
    end
  end

  def collect_dns_names
    ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY_ID, :secret_access_key => SECRET_ACCESS_KEY)
    sleep 3 while ! instances_ready(ec2)
    reservation_items = ec2.describe_instances["reservationSet"]["item"]
    @graph.each_node_parallel do |node|
      instance_id = node.info[:instance_id]
      instance = discover_instance instance_id, reservation_items
      node.info[:public_dns] = instance["dnsName"]
      node.info[:private_dns] = instance["privateDnsName"]
      @lock_states.synchronize do
        @nodes_state[node.info[:instance_id]][:dns] = instance["dnsName"]
      end
    end
  end

  def wait_ssh
    @graph.each_node_parallel do |node|
      sleep 3 while execute_command_on(node, Petals.ping) !~ /Petals/
      @nodes_state[node.info[:instance_id]][:ssh] = true
    end
  end

  def set_date
    @date = execute_command_on(@graph.root, "date '+%Y-%m-%d'", "2>/dev/null").strip
  end

  def set_up_topology_and_properties
    topology = Petals.create_topology_from @graph
    f = File.new "resources/topology.xml", 'w'
    f.puts topology
    f.close

    index = 0
    @graph.each_node do |node|
      f = File.new "resources/server.properties#{node.id}", 'w'
      f.puts Petals.server_properties index
      f.close
      index += 1
    end
  end


  def prepare_node_for_message node
    set_up_server node
    start_petals node
    populate_orchestration node
  end


  def set_up_server node
    scp_to node.info[:public_dns], "resources/topology.xml", "#{Petals::HOME}/conf/topology.xml"
    scp_to node.info[:public_dns], "resources/server.properties#{node.id}", "#{Petals::HOME}/conf/server.properties"
    @lock_states.synchronize do
      @nodes_state[node.info[:instance_id]][:topology] = true
    end
  end

  def start_petals node
    execute_command_on(node, Petals.stop)
    sleep 3 while execute_command_on(node, Petals.ping) !~ Petals::STOPPED
    execute_command_on(node, Petals.startup)
    sleep 3 while execute_command_on(node, Petals.ping) !~ Petals::RUNNING
    @lock_states.synchronize do
      @nodes_state[node.info[:instance_id]][:petals] = 'Running'
    end
    sleep 3  while execute_command_on(node, Petals.log_from(@date)) !~ Petals::BPEL_STARTED
    @lock_states.synchronize do
      @nodes_state[node.info[:instance_id]][:petals] = 'Ready'
    end
  end

  def populate_orchestration node
    if node.is_leaf?
      Orchestration.leaf_node node.id
      scp_to node.info[:public_dns], "resources/leaf_node#{node.id}/sa-BPEL-LeafNode#{node.id}-provide.zip", "#{Petals::HOME}/install/"
    else
      Orchestration.node node.id, node.children
      scp_to node.info[:public_dns], "resources/node#{node.id}/sa-BPEL-NodeNode#{node.id}-provide.zip", "#{Petals::HOME}/install/"
    end

    log = ""
    while log !~ Petals.sa_ready(node)
      log = execute_command_on(node, Petals.log_from(@date))
      if log =~ /java.util.zip.ZipException: error in opening zip file/
        puts "PAM!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        @lock_states.synchronize do
          @nodes_state[node.info[:instance_id]] = {:topology => false, :petals => 'Stopped'}
        end
        execute_command_on node, "rm -f #{Petals::HOME}/installed/sa-*"
        populate_orchestration node
      end
      sleep 3
    end
    @lock_states.synchronize do
      @nodes_state[node.info[:instance_id]][:orchestration] = true
    end
  end



  def collect_instances_id response
    response["instancesSet"]["item"].collect {|item| item["instanceId"]}
  end

  def discover_instance instance_id, reservation_items
    reservation_items.each do |reservation_item|
      reservation_item["instancesSet"]["item"].each do |instance|
        return instance if instance["instanceId"] == instance_id
      end
    end
  end

  def instances_ready ec2
    ec2.describe_instances["reservationSet"]["item"].each do |reservation_set|
      reservation_set["instancesSet"]["item"].each do |instance|
        return false if instance["instanceState"]["name"] == 'pending'
      end
    end
  end

  def execute_command_on node, command, output_management="2>&1"
    `ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{KEY_PATH} ec2-user@#{node.info[:public_dns]}  #{command}  #{output_management}`
  end

  def scp_to node, source, target
    `scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{KEY_PATH} #{source} ec2-user@#{node}:#{target} 2>/dev/null 1>/dev/null`
  end

end
