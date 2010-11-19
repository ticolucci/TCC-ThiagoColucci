#! /usr/bin/ruby


require 'net/http'
require 'net/https'
require 'benchmark'
include Benchmark          # we need the CAPTION and FMTSTR constants
require 'thread'

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
  mean = Tms.new
  s = Tms.new
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
  Tms.new(Math.sqrt(var.utime), Math.sqrt(var.stime), Math.sqrt(var.cutime), Math.sqrt(var.cstime), Math.sqrt(var.real))
end

def make_post http, service_path, msg, headers 
  $lock.synchronize do
      http.post service_path, msg, headers
    end
#      executed = true
#    rescue EOFError
#    rescue Errno::ECONNRESET
#    rescue IOError
#    rescue Errno::EPIPE
#    rescue NoMethodError
#    end
#  end
end


print_usage() if ARGV.size < 7

$lock = Mutex.new

host = ARGV.shift
port = ARGV.shift.to_i
service_path = ARGV.shift
node_id = ARGV.shift
message_size = ARGV.shift.to_i
frequency = ARGV.shift.to_i
period = 1.0/frequency
time = ARGV.shift.to_i
number_of_threads = time * frequency
number_of_tries = ARGV.shift.to_i

# Set Headers
headers = {
  'Referer' => 'http://localhost',
  'Content-Type' => 'text/xml',
  'Host' => host
}

msg_content = "a"*message_size
msg = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\">
  <SOAP-ENV:Body>
    <ns1:NodeOperation#{node_id} xmlns:ns1=\"http://localhost/NodeNode#{node_id}\">
        <Part>#{msg_content}</Part>
    </ns1:NodeOperation#{node_id}>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
"

msg_expected = "<?xml version='1.0' encoding='UTF-8'?><soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"><soapenv:Body><self:Message xmlns:self=\"http://localhost/NodeNode#{node_id}\">#{msg_content}</self:Message></soapenv:Body></soapenv:Envelope>"


http = Net::HTTP.new(host, port)
http.use_ssl = false



resp, data = http.post(service_path, msg, headers)

if data != msg_expected
  puts "Composition failed on deploy.
  Message received:"
  puts data
else
  
  str_len = "sending msg #{number_of_tries}".length
  std_dev_len = "> standard deviation:".length
  max_len = str_len > std_dev_len ? str_len : std_dev_len
  Benchmark.benchmark(" "*max_len + CAPTION, max_len, FMTSTR, "> total:", "> average:", "> variance:", "> standard deviation:") do |x|
    
    runs = []
    number_of_tries.times do |index|
      runs << x.report("sending msg #{index}") do
        pids = []
        number_of_threads.times do
          pids << Thread.new {make_post http, service_path, msg, headers }
          sleep period
        end
        pids.each {|pid| pid.join}
      end
    end

    total = runs.reduce(Tms.new) {|i,j| i+j}
    avg = total/number_of_tries
    var = variance(runs)
    std_dev = standard_deviation(runs)
    [total, avg, var, std_dev]
  end
  puts " "*max_len + CAPTION
end
