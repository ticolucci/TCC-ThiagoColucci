require 'thread'
class Ssh
  def initialize
    @lock_connection = Mutex.new
  end
  
  def execute_command_on host, command, output_management="2>&1"
    `ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no  ticolucci@#{host}  #{command}  #{output_management}`
  end

  def scp_to host, source, target
    @lock_connection.synchronize do
      `scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no #{source} ticolucci@#{host}:#{target} 2>/dev/null 1>/dev/null`
    end
  end 
end