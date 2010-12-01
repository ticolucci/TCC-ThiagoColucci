#! /usr/bin/ruby
require './lib/generator'
root_host = "localhost"; root_port = 8084; root_service_path = '/petals/services/NodeService1'; root_id = 1

puts "To use Send Message script:"
puts "./scripts/send_messages.rb #{root_host} #{root_port} #{root_service_path} \\"
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

children = ARGV.shift.to_i
depth = ARGV.shift.to_i

graph = Graph.new depth, children

graph.each_node do |node|
  node.info[:public_dns] = "localhost"
  node.info[:private_dns] = "localhost"
end


graph.each_node do |node|
  if node.is_leaf?
    Orchestration.leaf_node node.id
  else
    Orchestration.node node.id, node.children
  end
end