class Node
  attr_accessor :info
  attr_reader :parent
  
  def initialize parent
    @parent = parent
    @sons = []
  end
  
  def generate_n_levels_of_sons(deepth, number_of_sons)
    return if deepth == 0
    
    generate_sons(number_of_sons)
    @sons.each do |son|
      son.generate_n_levels_of_sons(deepth - 1, number_of_sons)
    end
  end
  
  def generate_sons number
    number.times do
      @sons << Node.new(self)
    end
  end
  
  def apply_for_all &func
    @sons.each do |son|
      func.call son
      son.apply_for_all(&func)
    end
  end
  
  def apply_for_all_parallel &func
    @sons.each do |son|
      Process.detach(fork do
        func.call son
      end)
      son.apply_for_all_parallel(&func)
    end
  end
  
  def is_leaf?
    @sons.empty?
  end
  
  def is_root?
    @parent.nil?
  end
end