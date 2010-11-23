require './conf/amazon_keys'
OPTS = "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

AMI = "ami-495ea920"

host = ARGV.shift
`ssh #{OPTS} -i #{KEY_PATH} ubuntu@#{host} ruby send_messages.rb #{ARGV.join ' '}`