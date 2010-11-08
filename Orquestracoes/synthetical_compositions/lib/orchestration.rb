require 'fileutils'
include FileUtils

class Orchestration
  def self.leaf_node id
    mkdir_p "resources/leaf_node#{id}"
    
    bpel = File.open("files_for_orchestration/leaf_node/bpel.xml", "r").readlines.join.gsub('#{id}', id.to_s)
    open_file_and_write "resources/leaf_node#{id}/LeafNode#{id}.bpel", bpel
    
    wsdl_definition = File.open("files_for_orchestration/leaf_node/wsdl_definition.xml", "r").readlines.join.gsub('#{id}', id.to_s)
    open_file_and_write "resources/leaf_node#{id}/LeafNodeDefinition#{id}.wsdl", wsdl_definition
    
    wsdl_artifacts = File.open("files_for_orchestration/leaf_node/wsdl_artifacts.xml", "r").readlines.join.gsub('#{id}', id.to_s)
    open_file_and_write "resources/leaf_node#{id}/LeafNodeArtifacts#{id}.wsdl", wsdl_artifacts    
    
    mkdir_p "resources/leaf_node#{id}/META-INF"
    jbi_BPEL = File.open("files_for_orchestration/leaf_node/jbi_BPEL.xml", "r").readlines.join.gsub('#{id}', id.to_s)
    open_file_and_write "resources/leaf_node#{id}/META-INF/jbi.xml", jbi_BPEL
    
    `zip -qXr9Djm resources/leaf_node#{id}/su-BPEL-LeafNode#{id}-provide.zip resources/leaf_node#{id}/LeafNode#{id}.bpel resources/leaf_node#{id}/LeafNodeDefinition#{id}.wsdl resources/leaf_node#{id}/LeafNodeArtifacts#{id}.wsdl 2>/dev/null` 
    cd "resources/leaf_node#{id}/" 
    `zip -qXr9Dm  su-BPEL-LeafNode#{id}-provide.zip META-INF 2>/dev/null`
    cd "../.."



    mkdir_p "resources/leaf_node#{id}/META-INF"
    jbi_SOAP = File.open("files_for_orchestration/leaf_node/jbi_SOAP.xml", "r").readlines.join.gsub('#{id}', id.to_s)
    open_file_and_write "resources/leaf_node#{id}/META-INF/jbi.xml", jbi_SOAP

    cd "resources/leaf_node#{id}/"
    `zip -qXr9Dm  su-SOAP-LeafService#{id}-consume.zip META-INF 2>/dev/null`
    cd "../.."
    
    
    mkdir_p "resources/leaf_node#{id}/META-INF"
    jbi_sa = File.open("files_for_orchestration/leaf_node/jbi_sa.xml", "r").readlines.join.gsub('#{id}', id.to_s)
    open_file_and_write "resources/leaf_node#{id}/META-INF/jbi.xml", jbi_sa

    `zip -qXr9Djm resources/leaf_node#{id}/sa-BPEL-LeafNode#{id}-provide.zip resources/leaf_node#{id}/su-SOAP-LeafService#{id}-consume.zip resources/leaf_node#{id}/su-BPEL-LeafNode#{id}-provide.zip 2>/dev/null` 
    cd "resources/leaf_node#{id}/"
    `zip -qXr9Dm sa-BPEL-LeafNode#{id}-provide.zip META-INF 2>/dev/null`
    cd "../.."
    
    
    rm_rf "resources/leaf_node#{id}/META-INF"
  end
  
  def self.open_file_and_write file_name, content
    file = File.new(file_name, "w")
    file.puts content
    file.close
  end
end