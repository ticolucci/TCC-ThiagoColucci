require './conf/amazon_keys'
OPTS = "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

AMI = "ami-fd5bac94"

host = ARGV.shift
`ssh #{OPTS} -i #{KEY_PATH} ubuntu@#{host} ruby send_messages.rb #{ARGV.join ' '}`