module NodeCreation

  def self.jbi_sa id, children
    response = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    
<jbi:jbi version=\"1.0\"
	xmlns=\"http://java.sun.com/xml/ns/jbi\"
	xmlns:jbi=\"http://java.sun.com/xml/ns/jbi\">

	<jbi:service-assembly>
		<jbi:identification>
			<jbi:name>sa-BPEL-NodeNode#{id}-provide</jbi:name>
			<jbi:description></jbi:description>
		</jbi:identification>
"
#    children.each do |child|
#      response <<"
#		<jbi:service-unit>
#			<jbi:identification>
#				<jbi:name>su-SOAP-#{child}Service#{child.id}-provide</jbi:name>
#				<jbi:description></jbi:description>
#			</jbi:identification>
#
#			<jbi:target>
#				<jbi:artifacts-zip>su-SOAP-#{child}Service#{child.id}-provide.zip</jbi:artifacts-zip>
#				<jbi:component-name>petals-bc-soap</jbi:component-name>
#			</jbi:target>
#		</jbi:service-unit>
#"
#    end
    response << "
		<!-- New service-unit -->
		<jbi:service-unit>
			<jbi:identification>
				<jbi:name>su-BPEL-NodeNode#{id}-provide</jbi:name>
				<jbi:description></jbi:description>
			</jbi:identification>

			<jbi:target>
				<jbi:artifacts-zip>su-BPEL-NodeNode#{id}-provide.zip</jbi:artifacts-zip>
				<jbi:component-name>petals-se-bpel</jbi:component-name>
			</jbi:target>
		</jbi:service-unit>

		<!-- New service-unit -->
		<jbi:service-unit>
			<jbi:identification>
				<jbi:name>su-SOAP-NodeService#{id}-consume</jbi:name>
				<jbi:description></jbi:description>
			</jbi:identification>

			<jbi:target>
				<jbi:artifacts-zip>su-SOAP-NodeService#{id}-consume.zip</jbi:artifacts-zip>
				<jbi:component-name>petals-bc-soap</jbi:component-name>
			</jbi:target>
		</jbi:service-unit>
	</jbi:service-assembly>
</jbi:jbi>"
  response
  end
end