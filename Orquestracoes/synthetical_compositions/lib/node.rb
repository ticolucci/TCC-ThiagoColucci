class Node
  attr_accessor :info
  attr_reader :parent, :children, :id
  @@index = 0

  def initialize parent
    @@index += 1
    @parent = parent
    @children = []
    @info = {}
    @id = @@index
  end
  
  def collect_nodes
    children.reduce(children) do |reduced, node|
      reduced + node.collect_nodes
    end
  end

  def generate_n_levels_of_children(depth, number_of_children)
    return if depth == 0

    generate_children(number_of_children)
    @children.each do |child|
      child.generate_n_levels_of_children(depth - 1, number_of_children)
    end
  end

  def generate_children number
    number.times do
      @children << Node.new(self)
    end
  end

  def apply_for_all &func
    @children.each do |child|
      func.call child
      child.apply_for_all(&func)
    end
  end

  def apply_for_all_parallel &func
    pids = []
    @children.each do |child|
      pids << Thread.new {func.call child }
      child.apply_for_all_parallel(&func)
    end
    pids.each {|pid| pid.join}
  end

  def is_leaf?
    @children.empty?
  end

  def is_root?
    @parent.nil?
  end

  alias :old_to_s :to_s
  def to_s
    if is_leaf?
      "Leaf"
    else
      "Node"
    end
  end

  def inspect; old_to_s; end
end
