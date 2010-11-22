module NodeCreation
  def self.child_jbi child
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>

    <jbi:jbi version=\"1.0\" 
		  xmlns:generatedNs=\"http://localhost/#{child}Node#{child.id}\"
    	xmlns:jbi=\"http://java.sun.com/xml/ns/jbi\"
    	xmlns:petalsCDK=\"http://petals.ow2.org/components/extensions/version-5\"
    	xmlns:soap=\"http://petals.ow2.org/components/soap/version-4\"
    	xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">

    	<jbi:services binding-component=\"true\">

    		<jbi:provides
    			interface-name=\"generatedNs:#{child}PortType#{child.id}\"
    			service-name=\"generatedNs:#{child}Service#{child.id}\"
    			endpoint-name=\"#{child}Port#{child.id}\">


    			<petalsCDK:validate-wsdl>true</petalsCDK:validate-wsdl>



    			<petalsCDK:wsdl>#{child}Node#{child.id}.wsdl</petalsCDK:wsdl>

    			<!-- Component specific elements -->
    			<soap:address>http://#{child.info[:private_dns]}:8084/petals/services/#{child}Service#{child.id}</soap:address>
    			<soap:soap-version>1.1</soap:soap-version>
    			<soap:chunked-mode>false</soap:chunked-mode>
    			<soap:cleanup-transport>true</soap:cleanup-transport>
    			<soap:mode>SOAP</soap:mode>

    		</jbi:provides>
    	</jbi:services>
    </jbi:jbi>"
  end
end