#! /usr/bin/ruby


require 'fileutils'
include FileUtils

PETALS_HOME = "/Users/ticolucci/Downloads/petals-platform-3.1.1"

date = "#{Time.now.year}-#{Time.now.month}-#{Time.now.day}"

services = Dir["./resources/*"]
services.sort! do |a,b|
  a =~ /\d+/
  id_a = $~.to_s.to_i
  
  b =~ /\d+/
  id_b = $~.to_s.to_i
  
  id_a <=> id_b
   
end
puts services

services.each do |service|
  service =~ /\d+/
  id = $~.to_s
  
  `cp #{service}/*.zip #{PETALS_HOME}/install `
  sleep 1 while `cat #{PETALS_HOME}/logs/petals#{date}.log` !~ /sa-.*#{id}.*started/
end