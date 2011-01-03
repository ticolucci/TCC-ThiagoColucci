name = ARGV.shift

require 'fileutils'
FileUtils.mkdir_p "results"

#[1, 5, 10].each do |frequency|
[1].each do |frequency|
  [100, 1_000, 1_000_000].each do |size|
    sleep 5
    f = File.new "results/#{name}_#{size}_#{frequency}.txt", "w"
    f.puts `date +%T`
    f.puts `ruby sc/scripts/send_messages.rb 192.168.65.1 8084 /petals/services/NodeService1 #{size} #{frequency} 50`
    f.puts `date +%T`
    f.puts "\n\n\n"
    f.close
    
    sleep 5
    `cp ~/a1/stats.log results/stat_#{name}_#{size}_#{frequency}_a1.dat`
    `cp ~/a2/stats.log results/stat_#{name}_#{size}_#{frequency}_a2.dat`
    `cp ~/a3/stats.log results/stat_#{name}_#{size}_#{frequency}_a3.dat`
    `rm a*/stat*`
  end
end