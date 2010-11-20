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
require './lib/ssh'
require './lib/printer'

#confs
require './conf/amazon_keys'

class Generator
  def initialize number_of_children, depth
    puts "Generating graph of relations..."
    @graph = Graph.new depth, number_of_children
    puts "done\n\n\n"
    @servers_started = 0
    @lock_servers_started = Mutex.new
    @ssh = Ssh.new KEY_PATH
  end

  def instantiate_compositions print_states
    ids = create_vms @graph.size
    distribute_ids ids
    
    @printer = print_states ? Printer.start(@graph.all_nodes) : Thread.new
    Signal.trap(0) do
      @printer.kill
      puts "Exit signal caught..."
      terminate_compositions
      exit 0
    end
    
    
    collect_dns_names
    wait_ssh
    set_date    
    set_up_topology_and_properties

    @graph.each_node_parallel do |node|
      prepare_node_for_message node
    end
  
    @printer.kill
  
    nodes_description
  
  
    root_node = @graph.root
    root_host = root_node.info[:public_dns]
    root_port = 8084
    root_service_path = "/petals/services/#{root_node}Service#{root_node.id}"
    return root_host, root_port, root_service_path, root_node.id
  end

  def terminate_compositions
    puts "Terminating instances..."
    ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY_ID, :secret_access_key => SECRET_ACCESS_KEY)
    @graph.each_node do |node|
      ec2.terminate_instances :instance_id => node.info[:instance_id]
    end
    rm_f "resources/topology.xml"
    Dir["resources/server.properties*"].each {|f| rm_f f} 
    rm_rf "resources/node*"
    rm_rf "resources/leaf*"
    puts "done\n\n\n"
  end

  private
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
    nodes = []
    @graph.each_node do |node|
      id = available_ids.shift
      node.info = {:instance_id => id}
      nodes << node
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
      @printer[node, :dns] = instance["dnsName"] 
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







  def wait_ssh
    @graph.each_node_parallel do |node|
      sleep 3 while @ssh.execute_command_on(node, Petals.ping) !~ /Petals/
      @printer[node, :ssh] = true
    end
  end

  def set_date
    @date = @ssh.execute_command_on(@graph.root, "date '+%Y-%m-%d'", "2>/dev/null").strip
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
    @ssh.scp_to node.info[:public_dns], "resources/topology.xml", "#{Petals::HOME}/conf/topology.xml"
    @ssh.scp_to node.info[:public_dns], "resources/server.properties#{node.id}", "#{Petals::HOME}/conf/server.properties"
    @printer[node, :topology] = true
  end

  def start_petals node
    @ssh.execute_command_on(node, Petals.stop)
    sleep 3 while @ssh.execute_command_on(node, Petals.ping) !~ Petals::STOPPED
    @ssh.execute_command_on(node, Petals.startup)
    sleep 3 while @ssh.execute_command_on(node, Petals.ping) !~ Petals::RUNNING
    @printer[node, :petals] = 'Running'
    sleep 3 while @ssh.execute_command_on(node, Petals.log_from(@date)) !~ Petals::BPEL_STARTED
    @printer[node, :petals] = 'Ready'

    @lock_servers_started.synchronize {@servers_started += 1}
    wait_other_servers
  end

  def wait_other_servers
    sleep 1 while @servers_started < @graph.size
  end

  def populate_orchestration node
    if node.is_leaf?
      Orchestration.leaf_node node.id
      @ssh.scp_to node.info[:public_dns], "resources/leaf_node#{node.id}/sa-BPEL-LeafNode#{node.id}-provide.zip", "#{Petals::HOME}/install/"
    else
      Orchestration.node node.id, node.children
      @ssh.scp_to node.info[:public_dns], "resources/node#{node.id}/sa-BPEL-NodeNode#{node.id}-provide.zip", "#{Petals::HOME}/install/"
    end

    log = ""
    while log !~ Petals.sa_ready(node)
      log = @ssh.execute_command_on(node, Petals.log_from(@date))
      if log =~ /java.util.zip.ZipException: error in opening zip file/
        @printer.reset node
        @lock_servers_started.synchronize {@servers_started -= 1}
        @ssh.execute_command_on node, "rm -f #{Petals::HOME}/installed/sa-*"
        prepare_node_for_message node
      end
      sleep 3
    end
    @printer[node, :orchestration] = true
  end


  
  
  
  def nodes_description
    puts "\n"*3
    puts "Nodes description:"
    @graph.each_node do |node|
      puts "#{ node.is_root? ? 'Root' : node}:"
      puts "http://#{node.info[:public_dns]}:8084/petals/services/#{node}Service#{node.id}"
      puts node.info[:public_dns]
      puts node.info[:private_dns]
      puts "id: #{node.id}"
      puts ''
    end
    puts "\n"*3
  end
end
