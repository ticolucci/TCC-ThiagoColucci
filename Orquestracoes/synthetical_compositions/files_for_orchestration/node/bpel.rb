module NodeCreation
  def self.bpel id, children
    response = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    
    <process name=\"NodeNode#{id}\" targetNamespace=\"http://localhost/NodeNode/bpel#{id}\"
    	xmlns=\"http://docs.oasis-open.org/wsbpel/2.0/process/executable\"
    	xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"
    	xmlns:self=\"http://localhost/NodeNode#{id}\" xmlns:artifacts=\"http://localhost/NodeNode/Artifacts#{id}\" 
      "
    	
    	children.each do |child|
    	  response << "xmlns:#{child.to_s.downcase}#{child.id}=\"http://localhost/#{child}Node#{child.id}\" "
  	  end
    	response << "
    	xmlns:bpel=\"http://docs.oasis-open.org/wsbpel/2.0/process/executable\" >

    	<import namespace=\"http://localhost/NodeNode#{id}\" location=\"NodeNodeDefinition#{id}.wsdl\"
    		importType=\"http://schemas.xmlsoap.org/wsdl/\" />

    	<import namespace=\"http://localhost/NodeNode/Artifacts#{id}\" location=\"NodeNodeArtifacts#{id}.wsdl\"
    		importType=\"http://schemas.xmlsoap.org/wsdl/\" />"
    		
    	children.each do |child|
        response << "
    	<import namespace=\"http://localhost/#{child}Node#{child.id}\" location=\"#{child}Node#{child.id}.wsdl\"
    		importType=\"http://schemas.xmlsoap.org/wsdl/\" />"
  		end
    	response << "
    	<partnerLinks>
    	"
    	children.each do |child|
    	  response << "
    		<partnerLink name=\"ChildNode#{child.id}\" partnerLinkType=\"artifacts:#{child}PartnerLinkType#{child.id}\"
    			partnerRole=\"#{child}#{child.id}\" />"
			end
			
			response << "
  		<partnerLink name=\"ParentNode\" partnerLinkType=\"artifacts:NodePartnerLinkType#{id}\"
    			myRole=\"NodeRole#{id}\" />
    	</partnerLinks>



    	<variables>"
    	
    	children.each_with_index do |child, index|
    	  response <<"
      		<variable name=\"in#{index+1}\" messageType=\"#{child.to_s.downcase}#{child.id}:Message\" />
    	  	<variable name=\"out#{index+1}\" messageType=\"#{child.to_s.downcase}#{child.id}:Message\" /> "
	  	end

    	response << "
    		<variable name=\"end\" messageType=\"self:Message\" />
    		<variable name=\"start\" messageType=\"self:Message\" />
    	</variables>



    	<sequence>
    		<receive name=\"start\" createInstance=\"yes\" partnerLink=\"ParentNode\"
    			operation=\"NodeOperation#{id}\" portType=\"self:NodePortType#{id}\" variable=\"start\" />

      "
      children.each_with_index do |child, index|
        response << "
    		<assign name=\"Assign#{index}\">
    			<copy>
    				<from variable=\"#{index == 0 ? "start" : "out#{index}"}\" />
    				<to variable=\"in#{index+1}\" />
    			</copy>
    		</assign>

    		<invoke name=\"Invoke#{index}\" partnerLink=\"ChildNode#{child.id}\" operation=\"#{child}Operation#{child.id}\"
    			portType=\"#{child.to_s.downcase}#{child.id}:#{child}PortType#{child.id}\" inputVariable=\"in#{index+1}\" outputVariable=\"out#{index+1}\" />"
    			
    		if index +1 == children.size
    		  response << "
    		<assign name=\"Assign#{index+1}\">
    			<copy>
    				<from variable=\"out#{index+1}\" />
    				<to variable=\"end\" />
    			</copy>
    		</assign> "
  		  end
  		end
  		
  		response << "
    		<reply name=\"end\" partnerLink=\"ParentNode\" operation=\"NodeOperation#{id}\"
    			portType=\"self:NodePortType#{id}\" variable=\"end\" />
    	</sequence>
    </process>"
    
    response
  end
end