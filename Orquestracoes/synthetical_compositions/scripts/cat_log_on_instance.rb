require './conf/amazon_keys'

ops = "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

host = ARGV.shift
now = Time.now
date = "#{now.year}-#{now.month}-#{now.hour >= 21 ? now.day + 1 : now.day}"
puts `ssh #{ops} -i #{KEY_PATH} ec2-user@#{host} cat petals-platform-3.1.1/logs/petals#{date}.log 2>&1`