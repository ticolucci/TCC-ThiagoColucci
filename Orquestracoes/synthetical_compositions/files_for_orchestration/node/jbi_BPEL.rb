module NodeCreation
  def self.jbi_BPEL id, children
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>

    <jbi:jbi version=\"1.0\" 
    
    	xmlns:bpel=\"http://petals.ow2.org/components/petals-bpel-engine/version-1\"
    	xmlns:jbi=\"http://java.sun.com/xml/ns/jbi\"
    	xmlns:petalsCDK=\"http://petals.ow2.org/components/extensions/version-5\"
    	xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">

    	<jbi:services binding-component=\"false\">

    		<jbi:provides
    			interface-name=\"generatedNs:NodePortType#{id}\"
    			service-name=\"generatedNs:NodeService#{id}\"
    			endpoint-name=\"NodePort#{id}\"
    			xmlns:generatedNs=\"http://localhost/NodeNode#{id}\">

    			<!-- CDK elements -->
    			<petalsCDK:validate-wsdl>true</petalsCDK:validate-wsdl>
    			<petalsCDK:wsdl>NodeNodeDefinition#{id}.wsdl</petalsCDK:wsdl>

    			<!-- Component specific elements -->
    			<bpel:bpel>NodeNode#{id}.bpel</bpel:bpel>
    			<bpel:poolsize>30</bpel:poolsize>

    		</jbi:provides>

    	</jbi:services>
    </jbi:jbi>
   " 
  end
end