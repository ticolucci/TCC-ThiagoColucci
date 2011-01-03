#! /usr/bin/ruby
require 'benchmark'
include Benchmark
require 'savon'

endpoint = ARGV[0]
msg_filename = ARGV[1]

f = File.open msg_filename, 'r'
msg = f.readlines
f.close

body = proc  {|soap| soap.body = {:part => msg}}
Savon::Request.log = false

client = Savon::Client.new "#{endpoint}?wsdl"
action = client.wsdl.soap_actions.first

response = nil
time = Benchmark.realtime do
  response = client.send(action,&body)
end

puts time
puts "\n\n--------------------------------------------------\n\n"
puts response.to_s