require './conf/amazon_keys'

ops = "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

host = ARGV.shift
date = Time.now.hour >= 21 ? Date.today + 1 : Date.today
puts `ssh #{ops} -i #{KEY_PATH} ec2-user@#{host} cat petals-platform-3.1.1/logs/petals#{date}.log 2>&1`