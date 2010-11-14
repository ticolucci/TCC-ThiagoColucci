module Petals
  HOME = "/home/ec2-user/petals-platform-3.1.1"
  STOPPED = /Petals STOPPED/
  RUNNING = /Petals RUNNING/
  BPEL_STARTED = /\[Petals.Container.Components.petals-se-bpel\]\s*Component started/

  def self.ping
    "export JAVA_HOME=/usr/lib/jvm/jre\\;#{Petals::HOME}/bin/ping.sh"
  end
  
  def self.startup
    "export JAVA_HOME=/usr/lib/jvm/jre\\;#{Petals::HOME}/bin/startup.sh -D"
  end
  
  def self.sa_ready node
    /Service Assembly 'sa-BPEL-#{node}Node#{node.id}-provide' started/
  end
  
  def self.log_from date
    "cat #{Petals::HOME}/logs/petals#{date}.log"
  end
  
  def self.create_topology_from graph
    top = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <tns:topology xmlns:tns=\"http://petals.ow2.org/topology\"
    	xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
    	xsi:schemaLocation=\"http://petals.ow2.org/topology petalsTopology.xsd\">
    	<tns:domain mode=\"static\" name=\"PEtALS\">
    		<tns:description>The static domain configuration</tns:description>
    		<tns:sub-domain name=\"subdomain1\" mode=\"flooding\">
    			<tns:description>description of the subdomain</tns:description>
    			"
    			
    index = 0
    graph.each_node do |node|
      top << "
			<tns:container name=\"#{index}\" type=\"peer\">
				<tns:description>description of the container #{index}</tns:description>
				<tns:host>#{node.info[:private_dns]}</tns:host>
				<tns:user>petals</tns:user>
				<tns:password>petals</tns:password>
				<tns:webservice-service>
					<tns:port>7600</tns:port>
					<tns:prefix>petals/ws</tns:prefix>
				</tns:webservice-service>
				<tns:jmx-service>
					<tns:rmi-port>7700</tns:rmi-port>
				</tns:jmx-service>
				<tns:transport-service>
					<tns:tcp-port>7800</tns:tcp-port>
				</tns:transport-service>
				<tns:registry-service>
					<tns:port>7900</tns:port>
				</tns:registry-service>
			</tns:container>
			
			"
			index += 1
    end
    
    top << "		</tns:sub-domain>
    	</tns:domain>
    </tns:topology>"
    
    top
  end
end