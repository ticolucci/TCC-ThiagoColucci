module NodeCreation
  def self.child_wsdl child
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    
    <definitions 
      xmlns=\"http://schemas.xmlsoap.org/wsdl/\"
    	xmlns:bpws=\"http://docs.oasis-open.org/wsbpel/2.0/varprop\"
    	xmlns:http=\"http://schemas.xmlsoap.org/wsdl/http/\"
    	xmlns:mime=\"http://schemas.xmlsoap.org/wsdl/mime/\"
    	xmlns:soap=\"http://schemas.xmlsoap.org/wsdl/soap/\" 
    	xmlns:wsdl=\"http://schemas.xmlsoap.org/wsdl/\"
    	xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" 
    	xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"
    	xmlns:tns=\"http://localhost/#{child}Node#{child.id}\"
    	
    	targetNamespace=\"http://localhost/#{child}Node#{child.id}\"
    	name=\"#{child}NodeDefinition#{child.id}\">
    	
    	
    	<types />
    	
    	<message name=\"Message\">
    		<part element=\"xs:string\" name=\"Part\" />
    	</message>
    	
    	<portType name=\"#{child}PortType#{child.id}\">
    		<operation name=\"#{child}Operation#{child.id}\">
    			<input message=\"tns:Message\" name=\"Input\" />
    			<output message=\"tns:Message\" name=\"Output\" />
    		</operation>
    	</portType>
    	
    	<binding name=\"#{child}Binding#{child.id}\" type=\"tns:#{child}PortType#{child.id}\">
    		<soap:binding style=\"document\" transport=\"http://schemas.xmlsoap.org/soap/http\" />
    		<operation name=\"#{child}Operation#{child.id}\">
    			<input name=\"Input\">
    				<soap:body use=\"literal\" />
    			</input>
    			<output name=\"Output\">
    				<soap:body use=\"literal\" />
    			</output>
    		</operation>
    	</binding>
    	
    	<service name=\"#{child}Service#{child.id}\">
    		<port binding=\"tns:#{child}Binding#{child.id}\" name=\"#{child}Port#{child.id}\">
    			<soap:address
    				location= \"http://#{child.info[:private_dns]}:8084/petals/services/#{child}Service#{child.id}\"/>
    		</port>
    	</service>
    </definitions>"
  end
end