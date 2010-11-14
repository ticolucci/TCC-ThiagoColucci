module NodeCreation
  def self.wsdl_definition id, children
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    
    <definitions xmlns=\"http://schemas.xmlsoap.org/wsdl/\"
    	xmlns:wsdl=\"http://schemas.xmlsoap.org/wsdl/\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"
    	xmlns:tns=\"http://localhost/NodeNode#{id}\" xmlns:soap=\"http://schemas.xmlsoap.org/wsdl/soap/\"
    	name=\"NodeNodeDefinition#{id}\" targetNamespace=\"http://localhost/NodeNode#{id}\">

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
    		<soap:binding style=\"document\"
    			transport=\"http://schemas.xmlsoap.org/soap/http\" />
    		<operation name=\"NodeOperation#{id}\">
    			<input name=\"Input\">
    				<soap:body use=\"literal\" />
    			</input>
    			<output name=\"Output\">
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