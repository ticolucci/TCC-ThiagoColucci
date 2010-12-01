#!/usr/bin/env ruby

require 'rubygems'
require 'AWS'

ACCESS_KEY_ID = 'AKIAIU37TNNJ3R4BWP3A'
SECRET_ACCESS_KEY = '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'

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

def terminate_all ec2
  ec2.describe_instances["reservationSet"]["item"].each do |reservation_item|
    reservation_item["instancesSet"]["item"].each do |instance|
      if instance["instanceState"]["name"] == "running" || instance["instanceState"]["name"] == "pending"
        ec2.terminate_instances :instance_id => instance["instanceId"]
      end
    end
  end
end

#p ec2.run_instances(:image_id => "ami-3ac33653", :min_count => 1, :max_count => 1, :key_name => "ticolucciKey", :instance_type => "t1.micro")
#ec2.terminate_instances :instance_id => "i-9807a5f5"

print_instances_details ec2
terminate_all ec2
#example = {"reservationId"=>"r-6f3afa05", "groupSet"=>{"item"=>[{"groupId"=>"default"}]}, "requestId"=>"26739269-8458-4bf9-a316-232e22b68189", "instancesSet"=>{"item"=>[{"stateReachild"=>{"code"=>"pending", "message"=>"pending"}, "keyName"=>"ticolucciKey", "blockDeviceMapping"=>nil, "productCodes"=>nil, "kernelId"=>"aki-407d9529", "launchTime"=>"2010-10-19T18:01:29.000Z", "amiLaunchIndex"=>"0", "imageId"=>"ami-3ac33653", "instanceType"=>"t1.micro", "reachild"=>nil, "rootDeviceName"=>"/dev/sda1", "rootDeviceType"=>"ebs", "placement"=>{"availabilityZone"=>"us-east-1d"}, "instanceId"=>"i-a267aecf", "privateDnsName"=>nil, "dnsName"=>nil, "monitoring"=>{"state"=>"disabled"}, "instanceState"=>{"name"=>"pending", "code"=>"0"}}]}, "ownerId"=>"689249284517", "xmlns"=>"http://ec2.amazonaws.com/doc/2009-11-30/"}

#instance_id = discover_instance_id example
#puts "instance_id == #{instance_id}"

#dns_name = discover_dns_name instance_id, ec2
#puts "dns_name == #{dns_name}"



#puts "----- listing images  -----"
#ec2.describe_images.imagesSet.item.each do |image|
#  # OpenStruct objects have members!
#  image.members.each do |member|
#    puts "#{member} => #{image[member]}"
#  end
#end
