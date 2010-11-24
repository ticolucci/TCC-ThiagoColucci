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
    @lock_filesystem = Mutex.new
    @petals = Petals.new
    set_date
  end

  def instantiate_compositions print_states
    distribute_ids
    
    @printer = print_states ? Printer.start(@graph.all_nodes) : Thread.new
    Signal.trap(0) do
      begin
        @printer.kill
        puts "Exit signal caught..."
        terminate_compositions
        exit 0
      end
    end 

    set_up_topology_and_properties

    @graph.each_node_parallel do |node|
      prepare_node_for_message node
    end
  
    @printer.kill
  
    nodes_description
  
  
    root_host = "192.168.65.1"
    root_port = 8084
    root_service_path = "/petals/services/#{root_node}Service#{root_node.id}"
    return root_host, root_port, root_service_path
  end

  def terminate_compositions
    puts "Terminating compositions..."
    @graph.each_node do |node|
      @petals.uninstall node
      @petals.stop node
      @petals.clear_log node, @date
    end
    rm_f "resources/topology.xml"
    Dir["resources/server.properties*"].each {|f| rm_f f} 
    rm_rf "resources/node*"
    rm_rf "resources/leaf*"
    puts "done\n\n\n"
  end

  private
  

  def distribute_ids
    ips = (1..8).collect {|i| "192.168.65.#{i}"}
    @graph.each_node do |node|
      node.info = {:ip => ips.shift}
    end
  end

  



  def set_date
    now = Time.now
    @date = "#{now.year}-#{now.month}-#{now.day}"
  end

  def set_up_topology_and_properties
    topology = @petals.create_topology_from @graph
    mkdir_p "resources"
    f = File.new "resources/topology.xml", 'w'
    f.puts topology
    f.close

    index = 0
    @graph.each_node do |node|
      f = File.new "resources/server.properties#{node.id}", 'w'
      f.puts @petals.server_properties index
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
    @printer[node, :topology] = false
    @petals.send_server_properties node
    @petals.send_topology node
    @printer[node, :topology] = true
  end

  def start_petals node
    @petals.startup node
    @printer[node, :petals] = 'Running'
    @petals.wait_bpel_to_start node, @date
    @printer[node, :petals] = 'Ready'

    @lock_servers_started.synchronize {@servers_started += 1}
    wait_other_servers
  end

  def wait_other_servers
    sleep 1 while @servers_started < @graph.size
  end

  def populate_orchestration node
    if node.is_leaf?
      @lock_filesystem.synchronize { Orchestration.leaf_node node.id }
      @petals.install node, "resources/leaf_node#{node.id}/sa-BPEL-#{node}Node#{node.id}-provide.zip"
    else
      @lock_filesystem.synchronize { Orchestration.node node.id, node.children }
      @petals.install node, "resources/node#{node.id}/sa-BPEL-#{node}Node#{node.id}-provide.zip"
    end

    log = ""
    while log !~ @petals.sa_ready(node)
      log = @petals.log_from node, @date
      if log =~ /java.util.zip.ZipException: error in opening zip file/
        puts log
        exit 0
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
      puts "http://#{node.info[:ip]}:8084/petals/services/#{node}Service#{node.id}"
      puts node.info[:ip]
      puts "id: #{node.id}"
      puts ''
    end
    puts "\n"*3
  end
end
