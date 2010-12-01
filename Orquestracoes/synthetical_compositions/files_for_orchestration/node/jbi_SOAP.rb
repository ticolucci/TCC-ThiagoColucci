module NodeCreation
  def self.jbi_SOAP id, children
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>

    <!-- JBI descriptor for the Petals component petals-bc-soap  -->
    <jbi:jbi version=\"1.0\" 
    	xmlns:jbi=\"http://java.sun.com/xml/ns/jbi\"
    	xmlns:petalsCDK=\"http://petals.ow2.org/components/extensions/version-5\"
    	xmlns:soap=\"http://petals.ow2.org/components/soap/version-4\"
    	xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">

    	<jbi:services binding-component=\"true\">

    		<jbi:consumes
    			interface-name=\"generatedNs:NodePortType#{id}\"
    			service-name=\"generatedNs:NodeService#{id}\"
    			endpoint-name=\"NodePort#{id}\"
    			xmlns:generatedNs=\"http://localhost/NodeNode#{id}\">

    			<!-- CDK elements -->
    			<petalsCDK:mep xsi:nil=\"true\" />

    			<!-- Component specific elements -->
    			<soap:address>NodeService#{id}</soap:address>
    			<soap:mode>SOAP</soap:mode>
    			<soap:rest-add-namespace-prefix>soapbc</soap:rest-add-namespace-prefix>

    		</jbi:consumes>

    	</jbi:services>
    </jbi:jbi>"
  end
end