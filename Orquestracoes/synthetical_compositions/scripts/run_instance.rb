#!/usr/bin/env ruby

require 'rubygems'
require 'AWS'
require 'amazon_keys'

def discover_instance_id response
    response["instancesSet"]["item"].first["instanceId"]
end

def discover_dns_name instance_id, ec2
  ec2.describe_instances["reservationSet"]["item"].each do |reservation_item|
    reservation_item["instancesSet"]["item"].each do |instance_item|
      if instance_item.find {|k,v| k == "instanceId" and v == instance_id}
        return instance_item["dnsName"]
      end
    end
  end
end

def wait_3_more_secs
  puts "Instances not ready yet. Waiting for 3 secs..."
  (1..3).to_a.reverse.each {|t| print "#{t},"; $stdout.flush(); sleep 1}
  puts "retry"
end

def instances_ready ec2
  ec2.describe_instances["reservationSet"]["item"].each do |reservation_set|
    reservation_set["instancesSet"]["item"].each do |instance|
      return false if instance["instanceState"]["name"] == 'pending'
    end
  end
end

  ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY_ID, :secret_access_key => SECRET_ACCESS_KEY)

instance_id = discover_instance_id ec2.run_instances(:image_id => AMI_ID, :min_count => 1, :max_count => 1, :key_name => KEY_NAME, :instance_type => "t1.micro", :security_group => "quick-start-1")
puts "instance_id == #{instance_id}"
while ! instances_ready ec2
  wait_3_more_secs
end
dns_name = discover_dns_name instance_id, ec2
puts "dns_name == #{dns_name}"
