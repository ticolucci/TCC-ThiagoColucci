module NodeCreation
  def self.wsdl_artifacts id, children
    response = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    
    <definitions xmlns=\"http://schemas.xmlsoap.org/wsdl/\"
    	xmlns:wsdl=\"http://schemas.xmlsoap.org/wsdl/\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"
    	xmlns:tns=\"http://localhost/NodeNode#{id}\" xmlns:plnk=\"http://docs.oasis-open.org/wsbpel/2.0/plnktype\"
    	targetNamespace=\"http://localhost/NodeNode/Artifacts#{id}\" "
    	
    	children.each do |child|
    	  response << "xmlns:#{child.to_s.downcase}#{child.id}=\"http://localhost/#{child}Node#{child.id}\" "
  	  end
  	  response << "name=\"NodeNodeArtifacts#{id}\"  > " #definitions
  	  
  	  children.each do |child|
    	  response << "
    	<import location=\"#{child}Node#{child.id}.wsdl\" namespace=\"http://localhost/#{child}Node#{child.id}\" />
    	<plnk:partnerLinkType name=\"#{child}PartnerLinkType#{child.id}\">
    		<plnk:role name=\"#{child}#{child.id}\" portType=\"#{child.to_s.downcase}#{child.id}:#{child}PortType#{child.id}\" />
    	</plnk:partnerLinkType> "
  	  end
    	
    	response << "
    	<import location=\"NodeNodeDefinition#{id}.wsdl\" namespace=\"http://localhost/NodeNode#{id}\" />
    	<plnk:partnerLinkType name=\"NodePartnerLinkType#{id}\">
    		<plnk:role name=\"NodeRole#{id}\" portType=\"tns:NodePortType#{id}\" />
    	</plnk:partnerLinkType>

    </definitions>
    "        
    response
  end  
end