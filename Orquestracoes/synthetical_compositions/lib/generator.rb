require 'lib/orchestration'
require 'lib/graph'
require 'lib/topology'
require 'rubygems'
require 'AWS'
require 'amazon_keys'
require 'fileutils'
include FileUtils
require 'lib/petals'

class Generator
  def initialize number_of_children, depth
    puts "Generating graph of relations..."
    @graph = Graph.new depth, number_of_children
    puts "done\n\n\n"
  end
  
  def instantiate_compositions
    ids = create_vms @graph.size
    distribute_ids ids
    collect_dns_names
    set_up_topology
    start_petals_in_each_node
    populate_orchestrations
    root_node = @graph.root
    root_endpoint = "http://#{root_node.info[:public_dns]}:8084/petals/services/#{root_node}Service#{root_node.id}"
    @graph.each_node do |node|
      puts "# Node:\nhttp://#{node.info[:public_dns]}:8084/petals/services/#{node}Service#{node.id}\nid: #{node.id}"      
    end
    return root_endpoint, root_node.id
  end
  
  def terminate_compositions
    puts "Terminating instances..."
    ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY_ID, :secret_access_key => SECRET_ACCESS_KEY)
    @graph.each_node do |node|
      ec2.terminate_instances :instance_id => node.info[:instance_id]
    end
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

    def collect_instances_id response
      response["instancesSet"]["item"].collect {|item| item["instanceId"]}
    end

    def collect_dns_names
      puts "Setting dns_name for each node..."
      ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY_ID, :secret_access_key => SECRET_ACCESS_KEY)
      while ! instances_ready(ec2)
        wait_3_more_secs "Instances not ready yet."
      end
      reservation_items = ec2.describe_instances["reservationSet"]["item"]
      @graph.each_node do |node|
        instance_id = node.info[:instance_id]
        instance = discover_instance instance_id, reservation_items
        node.info[:public_dns] = instance["dnsName"]
        node.info[:private_dns] = instance["privateDnsName"]
      end
      puts "done\n\n\n"
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
    
    def distribute_ids ids
      available_ids = ids.dup
      @graph.each_node do |node|
        node.info = {:instance_id => available_ids.shift}
      end
      
    end
    
    def wait_3_more_secs message
      puts message
      puts "Waiting for 3 secs..."
      (1..3).to_a.reverse.each {|t| print "#{t},"; $stdout.flush(); sleep 1}
      puts "retry"
    end

    def set_up_topology
      puts "Setting tpology in each node"
      topology = Petals.create_topology_from @graph
      f = File.new "resources/topology.xml", 'w'
      f.puts topology
      f.close
      
      @graph.each_node do |node| 
        wait_3_more_secs "SSH isn't ready for #{node}#{node.id}." while execute_command_on(node, Petals.ping) !~ Petals::STOPPED
        scp_to node.info[:public_dns], "resources/topology.xml", "#{Petals::HOME}/conf/topology.xml"
      end
      puts "\ndone\n\n\n"
    end


    def start_petals_in_each_node
      puts "Starting server in each node"
      @date = execute_command_on(@graph.root, "date '+%Y-%m-%d'", "2>/dev/null").strip
      @graph.each_node do |node|
        wait_3_more_secs "Petals isn't started on #{node}#{node.id}." while execute_command_on(node, Petals.ping) !~ Petals::RUNNING
        puts ''
        wait_3_more_secs "BPEL component isn't started on #{node}#{node.id}." while execute_command_on(node, Petals.log_from(@date)) !~ Petals::BPEL_STARTED
        puts "\n#{node} #{node.info[:public_dns]} is ready"
      end
      puts "\ndone\n\n\n"
    end

    def populate_orchestrations
      puts "Populating each node with its orchestration"
      @graph.each_node_parallel do |node|
        if node.is_leaf?
          Orchestration.leaf_node node.id
          scp_to node.info[:public_dns], "resources/leaf_node#{node.id}/sa-BPEL-LeafNode#{node.id}-provide.zip", "#{Petals::HOME}/install/"
          rm_rf "resources/leaf_node#{node.id}"
        else
          Orchestration.node node.id, node.children
          scp_to node.info[:public_dns], "resources/node#{node.id}/sa-BPEL-NodeNode#{node.id}-provide.zip", "#{Petals::HOME}/install/"
          rm_rf "resources/node#{node.id}"
        end
      end  
      @graph.each_node do |node|
        wait_3_more_secs "service assembly for #{node}#{node.id} isn't started" while execute_command_on(node, Petals.log_from(@date)) !~ Petals.sa_ready(node)
      end
      puts "done"
      puts "All services were sent to the cloud. But notice that they still might not be ready yet..."
    end
    
    
    def execute_command_on node, command, output_management="2>&1"
      `ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{KEY_PATH} ec2-user@#{node.info[:public_dns]}  #{command}  #{output_management}`
    end
    
    def scp_to node, source, target
      `scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{KEY_PATH} #{source} ec2-user@#{node}:#{target} 2>/dev/null 1>/dev/null`
    end
end