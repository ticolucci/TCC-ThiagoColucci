module NodeCreation
  def self.wsdl_definition id, children
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
    	xmlns:wsa=\"http://www.w3.org/2005/08/addressing\" 
    	xmlns:wsaw=\"http://www.w3.org/2006/05/addressing/wsdl\"
    	xmlns:tns=\"http://localhost/NodeNode#{id}\" 
    	
    	name=\"NodeNodeDefinition#{id}\" 
    	targetNamespace=\"http://localhost/NodeNode#{id}\">


    	<types />

    	<message name=\"Message\">
    		<part name=\"Part\" element=\"xsd:string\" />
    	</message>


    	<portType name=\"NodePortType#{id}\">
    		<operation name=\"NodeOperation#{id}\">
    			<input name=\"Input\" message=\"tns:Message\" />
    			<output name=\"Output\" message=\"tns:Message\" />
    		</operation>
    	</portType>


    	<binding name=\"NodeBinding#{id}\" type=\"tns:NodePortType#{id}\">
    		<soap:binding style=\"document\" transport=\"http://schemas.xmlsoap.org/soap/http\" />
    		<wsaw:UsingAddressing wsdl:required=\"true\" />
    		<operation name=\"NodeOperation#{id}\">
    			<input name=\"Input\" wsaw:Action=\"http://localhost/NodeNode#{id}/ActionIn\">
    				<soap:body use=\"literal\" />
    			</input>
    			<output name=\"Output\" wsaw:Action=\"http://localhost/NodeNode#{id}/ActionOut\">
    				<soap:body use=\"literal\" />
    			</output>
    		</operation>
    	</binding>

    	<service name=\"NodeService#{id}\">
    		<port name=\"NodePort#{id}\" binding=\"tns:NodeBinding#{id}\">
    			<soap:address location=\"NodeEndpoint#{id}\" />
    		</port>
    	</service>

    </definitions>
"  
  end
end