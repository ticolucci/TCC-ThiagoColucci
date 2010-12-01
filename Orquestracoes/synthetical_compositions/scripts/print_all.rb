#!/usr/bin/env ruby

require 'rubygems'
require 'AWS'
require './amazon_keys'

ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY_ID, :secret_access_key => SECRET_ACCESS_KEY)


def print_instances_details ec2
  puts "\n\n\n instances"
  ec2.describe_instances["reservationSet"]["item"].each do |item|
    puts "Reservation Set Item:  #{item.inspect}"
    item.each do |key, value|
      if key == "instancesSet"
        puts key.inspect
        value["item"].each_with_index {|i, index| puts "item #{index}:"; i.each {|k,v| puts "\t#{k.inspect} -> #{v.inspect}\n\n"}}
      else 
        puts "#{key.inspect} -> #{value.inspect}\n\n"
      end
    end
  end

  puts "\n\n\n"
end

print_instances_details ec2