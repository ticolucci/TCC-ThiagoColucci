require 'thread'
class Ssh
  def initialize key_path
    @key_path = key_path
    @lock_connection = Mutex.new
  end
  
  def execute_command_on node, command, output_management="2>&1"
    `ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{KEY_PATH} ec2-user@#{node.info[:public_dns]}  #{command}  #{output_management}`
  end

  def scp_to node, source, target
    @lock_connection.synchronize do
      `scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{KEY_PATH} #{source} ec2-user@#{node}:#{target} 2>/dev/null 1>/dev/null`
    end
  end 
end