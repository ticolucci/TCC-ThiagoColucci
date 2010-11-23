#! /usr/bin/ruby


require 'net/http'
require 'net/https'
require 'benchmark'
include Benchmark          # we need the CAPTION and FMTSTR constants
require 'thread'

require 'rubygems'
require 'savon'

def print_usage
  puts "Usage:"
  puts "\t$ ruby send_messages HOST PORT SERVICE_PATH NODE_ID MESSSAGE_SIZE FREQUENCY TIME NUMBER_OF_TRIES"
  puts "\n\n"
  puts "Where:"
  puts "\t HOST is where the service is hosted"
  puts "\t PORT is the port to the service"
  puts "\t SERVICE_PATH is where the path to the service from the host"
  puts "\t NODE_ID is the id of the Root Node of the composition"
  puts "\t MESSSAGE_SIZE is the size of each message [bytes]"
  puts "\t FREQUENCY is the frequency to send the messages [1/sec]"
  puts "\t TIME is for how long each test will last [sec]"
  puts "\t NUMBER_OF_TRIES is how many times we will run the test"
  
  exit 1
end



def variance(population)
  n = 0
  mean = 0.0 #Tms.new
  s = 0.0   #Tms.new
  population.each do |x|
    n += 1
    delta = x - mean
    mean = mean + (delta / n)
    tmp = delta * (x - mean)
    s = s + delta * (x - mean)
  end
  
  return s / n
end

def standard_deviation(population)
  var = variance(population)
  Math.sqrt(var)
  #Tms.new(Math.sqrt(var.utime), Math.sqrt(var.stime), Math.sqrt(var.cutime), Math.sqrt(var.cstime), Math.sqrt(var.real))
end

print_usage() if ARGV.size < 6

host = ARGV.shift
port = ARGV.shift.to_i
service_path = ARGV.shift
message_size = ARGV.shift.to_i
frequency = ARGV.shift.to_i
period = 1.0/frequency
number_of_threads = frequency
number_of_tries = ARGV.shift.to_i



msg_content = "a"*message_size

Savon::Request.log = false


client = Savon::Client.new "http://#{host}:#{port}#{service_path}?wsdl"
str_len = "sending msg #{number_of_tries}".length
std_dev_len = "> standard deviation: ".length + 2
max_len = str_len > std_dev_len ? str_len : std_dev_len

puts " "*max_len + "Real Time"
runs = []
number_of_tries.times do |index|
  runs << Benchmark.realtime do
    pids = []
    number_of_threads.times do
      pids << Thread.new {client.node_operation1 {|soap| soap.body = {:part => msg_content}}}
      sleep period
    end
    pids.each {|pid| pid.join}
  end
end


total = runs.reduce(0.0) {|i,j| i+j}
avg = total/number_of_tries
var = variance(runs)
std_dev = standard_deviation(runs)

puts "> total:              #{"%11.5f" % total} s"
puts "> average:            #{"%11.5f" % avg} s"
puts "> variance:           #{"%11.5f" % var} s"
puts "> standard deviation: #{"%11.5f" % std_dev} s"