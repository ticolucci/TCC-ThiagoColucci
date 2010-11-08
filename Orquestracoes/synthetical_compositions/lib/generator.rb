require 'lib/orchestration'
require 'lib/graph'
require 'rubygems'
require 'AWS'
require 'amazon_keys'
require 'fileutils'
include FileUtils

class Generator
  def initialize number_of_sons, deepth
    puts "Generating graph of relations..."
    @graph = Graph.new deepth, number_of_sons
    puts "done\n\n\n"
  end
  
  def instantiate_compositions
    ids = create_vms @graph.size
    distribute_ids ids
    collect_dns_names
    start_petals_in_each_node
    populate_orchestrations
    root_node = @graph.root
    puts "Root Node:\nhttp://#{root_node.info[:public_dns]}:8084/petals/services/LeafService#{root_node.object_id}\nid: #{root_node.object_id}"
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
        wait_3_more_secs
      end
      reservation_items = ec2.describe_instances["reservationSet"]["item"]
      @graph.each_node do |node|
        instance_id = node.info[:instance_id]
        instance = discover_instance instance_id, reservation_items
        node.info[:public_dns] = instance["dnsName"]
        node.info[:internal_dns] = instance["privateDnsName"]
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
    
    def wait_3_more_secs
      puts "Instances not ready yet. Waiting for 3 secs..."
      (1..3).to_a.reverse.each {|t| print "#{t},"; $stdout.flush(); sleep 1}
      puts "retry"
    end
   
    def start_petals_in_each_node
      puts "Starting server in each node"
      sleep 5
      @graph.each_node_parallel do |node|
        connect_again = true
        while connect_again
          response = execute_command_on node, "export JAVA_HOME=/usr/lib/jvm/jre\\;/home/ec2-user/petals-platform-3.1.1/bin/startup.sh -D"
          connect_again = response =~ /Connection refused/ || response =~ /Operation timed out/
        end
      end
      @graph.each_node do |node|
        while execute_command_on(node, "export JAVA_HOME=/usr/lib/jvm/jre\\;./petals-platform-3.1.1/bin/ping.sh") !~ /Petals RUNNING/
          print "."
          $stdout.flush()
          sleep 1
        end
        puts "\n#{node.is_leaf? ? 'Leaf' : node.is_root? ? 'Root' : 'Node'} #{node.info[:public_dns]} is running"
      end
      puts "\ndone\n\n\n"
    end
    
    def execute_command_on node, command
      `ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{KEY_PATH} ec2-user@#{node.info[:public_dns]}  #{command}  2>&1`
    end
    
    def scp_to node, source, target
      puts "going to run:\nscp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{KEY_PATH} #{source} ec2-user@#{node}:#{target} 2>/dev/null 1>/dev/null"
      `scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{KEY_PATH} #{source} ec2-user@#{node}:#{target} 2>/dev/null 1>/dev/null`
      puts "executed"
    end
    
    def populate_orchestrations
      puts "Populating each node with its orchestration"
      @graph.each_node_parallel do |node|
        Orchestration.leaf_node node.object_id
        3.times do
        scp_to node.info[:public_dns], 
               "resources/leaf_node#{node.object_id}/sa-BPEL-LeafNode#{node.object_id}-provide.zip", 
               "/home/ec2-user/petals-platform-3.1.1/install/"
        end
      end
      puts "done"
      puts "All services were sent to the cloud. But notice that they still might not be ready yet..."
    end
end