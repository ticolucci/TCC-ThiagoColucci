require "lib/node"

class Graph
  attr_reader :size, :root
  
  def initialize deepth, number_of_sons
    @root = Node.new nil
    @root.generate_n_levels_of_sons(deepth, number_of_sons)
    
    @size = (number_of_sons**(deepth+1))-1
  end
  
  def each_node &func
    func.call @root
    @root.apply_for_all(&func)
  end
  
  def each_node_parallel &func
    Process.detach(fork do
      func.call @root
    end)
    @root.apply_for_all_parallel &func
  end
end