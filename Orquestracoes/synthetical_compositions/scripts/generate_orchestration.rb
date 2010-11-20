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
root_host, root_port, root_service_path, root_id = generator.instantiate_compositions true

puts "\n\n\nRoot Host:"
puts root_host

puts "\n\n\nRoot Port:"
puts root_port

puts "\n\n\nRoot Service Path:"
puts root_service_path

puts "\n\n\nRoot Id:"
puts root_id

puts "\n"*4
puts "To use Send Message script:"
puts "./scripts/send_messages.rb #{root_host} #{root_port} #{root_service_path} #{root_id} \\"
puts "\n\n\n\n"

puts "To use Ode's send soap script:"

puts "\n\n<?xml version=\"1.0\" encoding=\"utf-8\" ?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\">
  <SOAP-ENV:Body>
    <ns1:NodeOperation#{root_id} xmlns:ns1=\"http://localhost/NodeNode#{root_id}\">
        <Part>Hello World!</Part>
    </ns1:NodeOperation#{root_id}>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>\n\n
"
puts "./bin/sendsoap http://#{root_host}:#{root_port}#{root_service_path} node_test_request.soap"


#puts "\n\n\n\n<?xml version=\"1.0\" encoding=\"utf-8\" ?>
#<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\">
#  <SOAP-ENV:Body>
#    <ns1:NodeOperation#{root_id} xmlns:ns1=\"http://localhost/NodeNode#{root_id}\">
#        <Part>#\{msg\}</Part>
#    </ns1:NodeOperation#{root_id}>
#  </SOAP-ENV:Body>
#</SOAP-ENV:Envelope>\n\n\n\n"


puts "Press 'q' to quit"
continue = true
continue while STDIN.getc.chr != 'q'


generator.terminate_compositions

#n1 = Node.new(nil)
#n1.instance_eval "def id; 2;end"
#n1.info[:public_dns] = "10.0.0.9"#"ec2-50-16-37-244.compute-1.amazonaws.com"
#n1.info[:private_dns] = "10.0.0.9"#"ip-10-122-178-51.ec2.internal"
#Orchestration.node 1, [n1]
#Orchestration.leaf_node 2