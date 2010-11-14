module NodeCreation
  def self.jbi_child_import_su child
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

    			<petalsCDK:timeout>30000</petalsCDK:timeout>
    			<petalsCDK:validate-wsdl>true</petalsCDK:validate-wsdl>
    			<petalsCDK:forward-security-subject>false</petalsCDK:forward-security-subject>
    			<petalsCDK:forward-message-properties>false</petalsCDK:forward-message-properties>
    			<petalsCDK:forward-attachments>false</petalsCDK:forward-attachments>
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