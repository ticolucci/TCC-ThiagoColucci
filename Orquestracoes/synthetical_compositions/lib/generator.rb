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
    @petals = Petals.new
    Ssh.new.execute_command_on(Petals::REVOADA, 'ls a1/petals-platform-3.1.1/logs/') =~ /petals(\d\d\d\d-\d\d-\d\d).log/
    @date = $1.to_s
  end

  def instantiate_compositions must_print = true
    distribute_ids
    
    @printer = Printer.start @graph.all_nodes, must_print
    Signal.trap(0) do
      begin
        @printer.kill
        puts "Exit signal caught..."
        terminate_compositions
        exit 0
      end
    end 


    @graph.each_node do |node|
      populate_orchestration node
    end
  
    @printer.kill
  
    nodes_description
  
  
    root_host = "192.168.65.1"
    root_port = 8084
    root_service_path = "/petals/services/NodeService1"
    return root_host, root_port, root_service_path
  end

  def terminate_compositions
    puts "Terminating compositions..."
    @graph.each_node do |node|
      puts "uninstalling #{node.id}"
      @petals.uninstall node, @dates
      puts "clearing log of #{node.id}"
      @petals.clear_log node, @date
    end
    puts "removing resources"
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

  

  def populate_orchestration node
    if node.is_leaf?
      Orchestration.leaf_node node.id
      @petals.install @date, node, "resources/leaf_node#{node.id}/sa-BPEL-#{node}Node#{node.id}-provide.zip"
    else
      Orchestration.node node.id, node.children
      @petals.install @date, node, "resources/node#{node.id}/sa-BPEL-#{node}Node#{node.id}-provide.zip"
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
