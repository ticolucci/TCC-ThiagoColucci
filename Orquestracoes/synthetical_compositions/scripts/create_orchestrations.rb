#! /usr/bin/ruby
require './lib/generator'
root_host = "localhost"; root_port = 8084; root_service_path = '/petals/services/NodeService1'; root_id = 1

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

n = ARGV.shift.to_i

@n1 = Node.new(nil)
(1...n).each do |i|
  a = eval "@n#{i+1} = Node.new(@n#{i})"
  a.info[:public_dns] = "localhost"
  a.info[:private_dns] = "localhost"
end

(1...n).each do |i|
  Orchestration.node i, [eval("@n#{i+1}")]
end

Orchestration.leaf_node n