require "./lib/node"

class Graph
  attr_reader :size, :root

  def initialize depth, number_of_children
    @root = Node.new nil
    @root.generate_n_levels_of_children(depth, number_of_children)

    @size = calculate_size number_of_children, depth
  end

  def each_node &func
    func.call @root
    @root.apply_for_all(&func)
  end

  def each_node_parallel &func
    pid = Thread.new { func.call @root }
    @root.apply_for_all_parallel &func
    pid.join
  end
  
  def all_nodes
    [@root] + @root.collect_nodes
  end

  private
  def calculate_size number_of_children, depth
    size = 1
    exp = 1
    depth.times do
      exp *= number_of_children
      size += exp
    end
    size
  end
end
