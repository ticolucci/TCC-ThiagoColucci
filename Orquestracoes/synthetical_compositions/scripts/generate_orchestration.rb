#! /usr/bin/ruby
require './lib/generator'

def print_usage
  puts "Usage:"
  puts "\t$ ruby generate_orchestration NUMBER_OF_CHILDREN DEPTH"
  puts "\n\n"
  puts "Where:"
  puts "\tNUMBER_OF_CHILDREN is how many children each node will have"
  puts "\tDEPTH is how far the messages will propagate from the root node untill"
  puts "the leaf node (the height of the tree)"
  
  exit 1
end

print_usage() if ARGV.size < 2

generator = Generator.new ARGV[0].to_i, ARGV[1].to_i
root_host, root_port, root_service_path = generator.instantiate_compositions

puts "\n\n\nRoot Host:"
puts root_host

puts "\n\n\nRoot Port:"
puts root_port

puts "\n\n\nRoot Service Path:"
puts root_service_path


puts "\n"*4
puts "To use Send Message script:"
puts "ruby ./scripts/send_messages.rb #{root_host} #{root_port} #{root_service_path} \\"
puts "\n\n\n\n"


puts "Hit 'CTRL+C' to quit"
sleep

generator.terminate_compositions