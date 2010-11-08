#! /usr/bin/ruby
require 'lib/generator'

def print_usage
  puts "Usage:"
  puts "\t$ ruby generate_orchestration NUMBER_OF_PARTNER_LINKS DEEPTH"
  puts "\n\n"
  puts "Where:"
  puts "\tNUMBER_OF_PARTNER_LINKS is how many partner links each node will have"
  puts "\tDEEPTH is how far the messages will propagate from the root node untill"
  puts "the leaf node (the height of the tree)"
  
  exit 1
end

print_usage() if ARGV.size < 2

generator = Generator.new ARGV[0].to_i, ARGV[1].to_i
generator.instantiate_compositions

puts "Press 'q' to quit"
continue = true
continue while STDIN.getc.chr != 'q'


generator.terminate_compositions