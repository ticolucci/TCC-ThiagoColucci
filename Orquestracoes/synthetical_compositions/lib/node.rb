class Node
  attr_accessor :info
  attr_reader :parent, :children

  def initialize parent
    @parent = parent
    @children = []
    @info = {}
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
    @children.each do |child|
      Process.detach(fork do
        func.call child
      end)
      child.apply_for_all_parallel(&func)
    end
  end

  def is_leaf?
    @children.empty?
  end

  def is_root?
    @parent.nil?
  end

  def to_s
    if is_leaf?
      "Leaf"
    else
      "Node"
    end
  end

  alias :id :object_id
end
