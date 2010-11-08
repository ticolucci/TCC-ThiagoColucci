require "lib/generator"

describe Generator do
  it "should be initialized with the kind of the composition to generate, the number of sons for each node, how deep the sequence will be and the " do
    Generator.new Orchestration, 1, 1
  end
  
  it "should generate a root node" do
    generator = Generator.new Orchestration, 1, 1
  end
end