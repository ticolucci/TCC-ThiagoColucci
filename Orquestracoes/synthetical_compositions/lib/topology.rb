module TopologyCreator
  def self.topology graph
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
  end
  
  
end