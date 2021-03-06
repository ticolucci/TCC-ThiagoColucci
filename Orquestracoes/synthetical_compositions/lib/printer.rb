require 'thread'
require './lib/color_text'

class Printer
  def initialize nodes
    @lock_screen = Mutex.new
    @nodes = {}
    nodes.each do |node|
      @nodes[node.id] = {:orchestration => false, :node => node}
    end
  end
  
  def self.start nodes, must_print
    p = Printer.new nodes
    p.start if must_print
    p
  end
  
  def start
    @micro_id = micro_printer
    puts "\e[H\e[2J"
    @thread_id = Thread.new do
      loop {
        @lock_screen.synchronize do
          puts "\e[H"

          header = "#   State \\ Instance         aguia" + @nodes.keys.join("           aguia") + "     #"
          puts "\n"*5
          puts "\t\t" + ("#" * header.size)
          puts "\t\t" + header
          puts "\t\t#"                          + (" " *(header.size - 2))      +     "#"
          
          puts "\t\t#  orchestration running  " + collect_state(:orchestration) + "    #"
          puts "\t\t" + ("#" * header.size)
          puts "\n" *10
          puts "\e[40;0H\n"
        end
            
        sleep 1
      }
    end
  end
  
  def collect_state name
    l = "aguia".size
    states = @nodes.keys.collect do |k|
      if name == :petals
         status_of_petals @nodes[k][:petals], k.size+l
      else 
        ok_or_not_ok k, name
      end
    end
    states.join("    ")
  end

  def ok_or_not_ok key, field
    la = "aguia".size
    s,l = (@nodes[key][field] ? [ColorText.green("Yes"),3] : [ColorText.red("No"),2])
    s.center(s.size + la + key.size - l) 
  end
  
  def []= node, state_id, new_state
    @lock_screen.synchronize {@nodes[node.id][state_id] = new_state}
  end
  
  def kill
    Thread.kill @thread_id
    Thread.kill @micro_id unless @micro_id.nil?
    puts "\e[100;0H"
  end
  
  def micro_printer
    t = 0.15
    Thread.new do
      loop do
        @lock_screen.synchronize {puts "\e[2;5H\n" + ("|" * 40) + "\n\e[40;0H\n"}
        sleep t
        @lock_screen.synchronize {puts "\e[2;5H\n" + ("/" * 40) + "\n\e[40;0H\n"}
        sleep t
        @lock_screen.synchronize {puts "\e[2;5H\n" + ("-" * 40) + "\n\e[40;0H\n"}
        sleep t
        @lock_screen.synchronize {puts "\e[2;5H\n" + ("\\" * 40) + "\n\e[40;0H\n"}
        sleep t
      end
    end
  end
end