require 'thread'
require './lib/color_text'

class Printer
  def initialize nodes
    @lock_screen = Mutex.new
    @nodes = {}
    nodes.each do |node|
      @nodes[node.info[:instance_id]] = {:dns => false, :topology => false, :petals => 'Stopped', :orchestration => false, :node => node, :ssh => false}
    end
  end
  
  def self.start nodes
    p = Printer.new nodes
    p.start
    p
  end
  
  def start
    @micro_id = micro_printer
    puts "\e[H\e[2J"
    @thread_id = Thread.new do
      loop {
        @lock_screen.synchronize do
          puts "\e[H"

          header = "#   State \\ Instance     " + @nodes.keys.join("    ") + "     #"
          puts "\n"*5
          puts "\t\t" + ("#" * header.size)
          puts "\t\t" + header
          
          puts "\t\t#"                          + (" " *(header.size - 2))      +     "#"
          puts "\t\t#"                          + (" " *(header.size - 2))      +     "#"
          puts "\t\t#       dns set           " + collect_state(:dns)           + "    #"
          puts "\t\t#"                          + (" " *(header.size - 2))      +     "#"
          puts "\t\t#      ssh ready          " + collect_state(:ssh)           + "    #"
          puts "\t\t#"                          + (" " *(header.size - 2))      +     "#"
          puts "\t\t#     topology sent       " + collect_state(:topology)      + "    #"
          puts "\t\t#"                          + (" " *(header.size - 2))      +     "#"
          puts "\t\t#     petals state        " + collect_state(:petals)        + "    #"
          puts "\t\t#"                          + (" " *(header.size - 2))      +     "#"
          puts "\t\t#  orchestration running  " + collect_state(:orchestration) + "    #"
          puts "\t\t" + ("#" * header.size)
          puts "\n" *10
          @nodes.keys.each do |k|
            dns = @nodes[k][:dns]
            if dns
              puts "\t\t#{k} -> #{dns}" 
            else
              node = @nodes[k][:node]
              puts "\t\t#{node} => #{node.inspect}"
            end
          end
          puts "\n"*3
          puts "\e[60;0H\n"
        end
            
        sleep 1
      }
    end
  end
  
  def collect_state name
    states = @nodes.keys.collect do |k|
      if name == :petals
         status_of_petals @nodes[k][:petals], k.size
      else 
        ok_or_not_ok k, name
      end
    end
    states.join("    ")
  end

  def ok_or_not_ok key, field
    s,l = (@nodes[key][field] ? [ColorText.green("Yes"),3] : [ColorText.red("No"),2])
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
  
  def []= node, state_id, new_state
    @lock_screen.synchronize {@nodes[node.info[:instance_id]][state_id] = new_state}
  end
  
  def kill
    Thread.kill @thread_id
    Thread.kill @micro_id unless @micro_id.nil?
    puts "\e[100;0H"
  end
  
  def micro_printer
    t = 0.1
    Thread.new do
      loop do
        @lock_screen.synchronize {puts "\e[2;5H\n" + ("|" * 40) + "\n\e[60;0H\n"}
        sleep t
        @lock_screen.synchronize {puts "\e[2;5H\n" + ("/" * 40) + "\n\e[60;0H\n"}
        sleep t
        @lock_screen.synchronize {puts "\e[2;5H\n" + ("-" * 40) + "\n\e[60;0H\n"}
        sleep t
        @lock_screen.synchronize {puts "\e[2;5H\n" + ("\\" * 40) + "\n\e[60;0H\n"}
        sleep t
      end
    end
  end
end