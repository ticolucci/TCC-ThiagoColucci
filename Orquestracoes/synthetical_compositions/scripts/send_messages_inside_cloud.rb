name = ARGV.shift

require 'fileutils'
FileUtils.mkdir_p "results"

[10, 100].each do |frequency|
  [1_000, 1_000_000].each do |size|
    f = File.new "results/#{name}_#{size}_#{frequency}.txt", "w"
    f.puts `ssh ticolucci@aguia1.ime.usp.br "ssh aguia8 export GEM_HOME=/home/ticolucci/.rvm/gems/ruby-1.9.2-p0; .rvm/rubies/ruby-1.9.2-p0/bin/ruby sc/scripts/send_messages.rb 192.168.65.1 8084 /petals/services/NodeService1 #{size} #{frequency} 100"`
    f.close
  end
end