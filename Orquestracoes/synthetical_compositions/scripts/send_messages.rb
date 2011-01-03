#! /usr/bin/ruby
# 
# $: << '/home/ticolucci/.rvm/gems/ruby-1.9.2-p0'
# $: << '/home/ticolucci/.rvm/gems/ruby-1.9.2-p0/gems'
# $: << '/home/ticolucci/.rvm/gems/ruby-1.9.2-p0/gems/savon-0.7.9'
require 'thread'


def print_usage
  puts "Usage:"
  puts "\t$ ruby send_messages HOST PORT SERVICE_PATH MESSSAGE_SIZE FREQUENCY EXPERIMENT_DURATION"
  puts "\n\n"
  puts "Where:"
  puts "\t HOST is where the service is hosted"
  puts "\t PORT is the port to the service"
  puts "\t SERVICE_PATH is where the path to the service from the host"
  puts "\t MESSSAGE_SIZE is the size of each message [bytes]"
  puts "\t FREQUENCY is the frequency to send the messages [1/sec]"
  puts "\t EXPERIMENT_DURATION is how many times we will run the test"
  
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

def send_msg endpoint, msg
  msg_filename = "/tmp/msg_#{(rand * 100_000_000_000_000_000).to_i}"
  f = File.new msg_filename, "w"
  f.puts msg
  f.close
  r = `ruby ./sc/scripts/send_a_message.rb #{endpoint} #{msg_filename}`
  a = r.split
  time = a.shift.to_f
  a.shift #separator
  response = a.join "\n"
  [time, response]
end




print_usage() if ARGV.size < 6

host = ARGV.shift
port = ARGV.shift.to_i
service_path = ARGV.shift
message_size = ARGV.shift.to_i
frequency = ARGV.shift.to_i
period = 1.0/frequency
experiment_duration = ARGV.shift.to_i

lock = Mutex.new

msg = "a"*message_size
endpoint = "http://#{host}:#{port}#{service_path}"

str_len = "sending msg 1000000000000000".length
std_dev_len = "> standard deviation: ".length + 2
max_len = str_len > std_dev_len ? str_len : std_dev_len

puts " "*max_len + "Real Time"
run, default_response = send_msg endpoint, msg
runs = []
threads = []
my_period = 0
sleeps = []
(experiment_duration/period).to_i.times do |i|
  sleeps << my_period
  my_period += period
end

sleeps.each do |sleep_time|
  threads << Thread.new do\
    sleep sleep_time
    
    run,response = send_msg endpoint, msg
    
    throw ("Got:"+response+"          Expected:"+default_response) if default_response != response
    
    lock.synchronize {runs << run}
  end
end

threads.each {|t| t.join}


total = runs.reduce(0.0) {|i,j| i+j}
avg = total/sleeps.size
std_dev = standard_deviation(runs)

puts "> total:              #{"%11.5f" % total} s"
puts "> average:            #{"%11.5f" % avg} s"
puts "> standard deviation: #{"%11.5f" % std_dev} s"