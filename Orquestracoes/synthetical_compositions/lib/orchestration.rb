Dir['files_for_orchestration/node/*.rb'].each { |file| require file}
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

  def self.node id, children
    mkdir_p "resources/node#{id}"

    bpel = NodeCreation.bpel id,children
    open_file_and_write "resources/node#{id}/NodeNode#{id}.bpel", bpel
    `zip -qXr9Djm resources/node#{id}/su-BPEL-NodeNode#{id}-provide.zip resources/node#{id}/NodeNode#{id}.bpel 2>/dev/null`

    wsdl_definition = NodeCreation.wsdl_definition id,children
    open_file_and_write "resources/node#{id}/NodeNodeDefinition#{id}.wsdl", wsdl_definition
    `zip -qXr9Djm resources/node#{id}/su-BPEL-NodeNode#{id}-provide.zip resources/node#{id}/NodeNodeDefinition#{id}.wsdl 2>/dev/null`

    wsdl_artifacts = NodeCreation.wsdl_artifacts id,children
    open_file_and_write "resources/node#{id}/NodeNodeArtifacts#{id}.wsdl", wsdl_artifacts
    `zip -qXr9Djm resources/node#{id}/su-BPEL-NodeNode#{id}-provide.zip resources/node#{id}/NodeNodeArtifacts#{id}.wsdl 2>/dev/null`


    children.each do |child|
      child_wsdl = NodeCreation.child_wsdl child
      open_file_and_write "resources/node#{id}/#{child}Node#{child.id}.wsdl", child_wsdl
      `zip -qXr9Djm resources/node#{id}/su-BPEL-NodeNode#{id}-provide.zip resources/node#{id}/#{child}Node#{child.id}.wsdl 2>/dev/null`


      open_file_and_write "resources/node#{id}/#{child}Node#{child.id}.wsdl", child_wsdl
      `zip -qXr9Djm resources/node#{id}/su-SOAP-#{child}Service#{child.id}-provide.zip resources/node#{id}/#{child}Node#{child.id}.wsdl 2>/dev/null`

      make_META_INF id
      child_jbi = NodeCreation.jbi_child_import_su child
      open_file_and_write "resources/node#{id}/META-INF/jbi.xml", child_jbi

      cd "resources/node#{id}/"
      `zip -qXr9Dm su-SOAP-#{child}Service#{child.id}-provide.zip META-INF 2>/dev/null`
      cd "../.."

      `zip -qXr9Djm resources/node#{id}/sa-BPEL-NodeNode#{id}-provide.zip resources/node#{id}/su-SOAP-#{child}Service#{child.id}-provide.zip 2>/dev/null`
    end

    make_META_INF id
    jbi_BPEL = NodeCreation.jbi_BPEL id, children
    open_file_and_write "resources/node#{id}/META-INF/jbi.xml", jbi_BPEL

    cd "resources/node#{id}/"
    `zip -qXr9Dm  su-BPEL-NodeNode#{id}-provide.zip META-INF 2>/dev/null`
    cd "../.."
    `zip -qXr9Djm resources/node#{id}/sa-BPEL-NodeNode#{id}-provide.zip resources/node#{id}/su-BPEL-NodeNode#{id}-provide.zip 2>/dev/null`


    make_META_INF id
    jbi_SOAP = NodeCreation.jbi_SOAP id, children
    open_file_and_write "resources/node#{id}/META-INF/jbi.xml", jbi_SOAP

    cd "resources/node#{id}/"
    `zip -qXr9Dm  su-SOAP-NodeService#{id}-consume.zip META-INF 2>/dev/null`
    cd "../.."
    `zip -qXr9Djm resources/node#{id}/sa-BPEL-NodeNode#{id}-provide.zip resources/node#{id}/su-SOAP-NodeService#{id}-consume.zip 2>/dev/null`


    make_META_INF id
    jbi_sa = NodeCreation.jbi_sa id, children
    open_file_and_write "resources/node#{id}/META-INF/jbi.xml", jbi_sa

    cd "resources/node#{id}/"
    `zip -qXr9Dm sa-BPEL-NodeNode#{id}-provide.zip META-INF 2>/dev/null`
    cd "../.."






    #children.each do |child|
    #  child_wsdl = NodeCreation.child_wsdl child
    #  open_file_and_write "resources/node#{id}/#{child}Node#{child.id}.wsdl", child_wsdl
    #  `zip -qXr9Djm resources/node#{id}/su-SOAP-#{child}Node#{child.id}-provide.zip resources/node#{id}/#{child}Node#{child.id}.wsdl 2>/dev/null`
    #
    #  make_META_INF id
    #  jbi_child_import_su = NodeCreation.jbi_child_import_su child
    #  open_file_and_write "resources/node#{id}/META-INF/jbi.xml", jbi_child_import_su
    #
    #  cd "resources/node#{id}/"
    #  `zip -qXr9Dm su-SOAP-#{child}Node#{child.id}-provide.zip META-INF 2>/dev/null`
    #  cd "../.."
    #
    #
    #
    #
    #  `zip -qXr9Djm resources/node#{id}/sa-SOAP-#{child}Node#{child.id}-provide.zip resources/node#{id}/su-SOAP-#{child}Node#{child.id}-provide.zip 2>/dev/null`
    #
    #  make_META_INF id
    #  jbi_child_import_sa = NodeCreation.jbi_child_import_sa child
    #  open_file_and_write "resources/node#{id}/META-INF/jbi.xml", jbi_child_import_sa
    #
    #
    #  cd "resources/node#{id}/"
    #  `zip -qXr9Dm sa-SOAP-#{child}Node#{child.id}-provide.zip META-INF 2>/dev/null`
    #  cd "../.."
    #end


    rm_rf "resources/node#{id}/META-INF"
  end

  def self.open_file_and_write file_name, content
    file = File.new(file_name, "w")
    file.puts content
    file.close
  end

  def self.make_META_INF id
    mkdir_p "resources/node#{id}/META-INF"
  end
end
