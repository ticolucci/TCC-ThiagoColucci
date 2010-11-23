Dir['./files_for_orchestration/node/*.rb'].each { |file| require file}
require 'fileutils'
include FileUtils

module Orchestration
  module_function
  def leaf_node id
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

    zip_j "resources/leaf_node#{id}/su-BPEL-LeafNode#{id}-provide.zip",
        "resources/leaf_node#{id}/LeafNode#{id}.bpel", "resources/leaf_node#{id}/LeafNodeDefinition#{id}.wsdl", "resources/leaf_node#{id}/LeafNodeArtifacts#{id}.wsdl"
    cd "resources/leaf_node#{id}/"
    zip "su-BPEL-LeafNode#{id}-provide.zip", "META-INF"
    cd "../.."



    mkdir_p "resources/leaf_node#{id}/META-INF"
    jbi_SOAP = File.open("files_for_orchestration/leaf_node/jbi_SOAP.xml", "r").readlines.join.gsub('#{id}', id.to_s)
    open_file_and_write "resources/leaf_node#{id}/META-INF/jbi.xml", jbi_SOAP

    cd "resources/leaf_node#{id}/"
    zip "su-SOAP-LeafService#{id}-consume.zip", "META-INF"
    cd "../.."


    mkdir_p "resources/leaf_node#{id}/META-INF"
    jbi_sa = File.open("files_for_orchestration/leaf_node/jbi_sa.xml", "r").readlines.join.gsub('#{id}', id.to_s)
    open_file_and_write "resources/leaf_node#{id}/META-INF/jbi.xml", jbi_sa

    zip_j "resources/leaf_node#{id}/sa-BPEL-LeafNode#{id}-provide.zip", "resources/leaf_node#{id}/su-SOAP-LeafService#{id}-consume.zip", "resources/leaf_node#{id}/su-BPEL-LeafNode#{id}-provide.zip"
    cd "resources/leaf_node#{id}/"
    zip "sa-BPEL-LeafNode#{id}-provide.zip", "META-INF"
    cd "../.."


    rm_rf "resources/leaf_node#{id}/META-INF"
  end

  def node id, children
    mkdir_p "resources/node#{id}"

    bpel = NodeCreation.bpel id,children
    open_file_and_write "resources/node#{id}/NodeNode#{id}.bpel", bpel
    zip_j "resources/node#{id}/su-BPEL-NodeNode#{id}-provide.zip", "resources/node#{id}/NodeNode#{id}.bpel"

    wsdl_definition = NodeCreation.wsdl_definition id,children
    open_file_and_write "resources/node#{id}/NodeNodeDefinition#{id}.wsdl", wsdl_definition
    zip_j "resources/node#{id}/su-BPEL-NodeNode#{id}-provide.zip", "resources/node#{id}/NodeNodeDefinition#{id}.wsdl"

    wsdl_artifacts = NodeCreation.wsdl_artifacts id,children
    open_file_and_write "resources/node#{id}/NodeNodeArtifacts#{id}.wsdl", wsdl_artifacts
    zip_j "resources/node#{id}/su-BPEL-NodeNode#{id}-provide.zip", "resources/node#{id}/NodeNodeArtifacts#{id}.wsdl"


    children.each do |child|
      child_wsdl = NodeCreation.child_wsdl child
      open_file_and_write "resources/node#{id}/#{child}Node#{child.id}.wsdl", child_wsdl
      zip_j "resources/node#{id}/su-BPEL-NodeNode#{id}-provide.zip", "resources/node#{id}/#{child}Node#{child.id}.wsdl"


      open_file_and_write "resources/node#{id}/#{child}Node#{child.id}.wsdl", child_wsdl
      zip_j "resources/node#{id}/su-SOAP-#{child}Service#{child.id}-provide.zip", "resources/node#{id}/#{child}Node#{child.id}.wsdl"

      make_META_INF id
      child_jbi = NodeCreation.jbi_child_import_su child
      open_file_and_write "resources/node#{id}/META-INF/jbi.xml", child_jbi

      cd "resources/node#{id}/"
      zip "su-SOAP-#{child}Service#{child.id}-provide.zip", "META-INF"
      cd "../.."

      zip_j "resources/node#{id}/sa-BPEL-NodeNode#{id}-provide.zip", "resources/node#{id}/su-SOAP-#{child}Service#{child.id}-provide.zip"
    end

    make_META_INF id
    jbi_BPEL = NodeCreation.jbi_BPEL id, children
    open_file_and_write "resources/node#{id}/META-INF/jbi.xml", jbi_BPEL

    cd "resources/node#{id}/"
    zip "su-BPEL-NodeNode#{id}-provide.zip", "META-INF"
    cd "../.."
    zip_j "resources/node#{id}/sa-BPEL-NodeNode#{id}-provide.zip", "resources/node#{id}/su-BPEL-NodeNode#{id}-provide.zip"


    make_META_INF id
    jbi_SOAP = NodeCreation.jbi_SOAP id, children
    open_file_and_write "resources/node#{id}/META-INF/jbi.xml", jbi_SOAP

    cd "resources/node#{id}/"
    zip "su-SOAP-NodeService#{id}-consume.zip", "META-INF"
    cd "../.."
    zip_j "resources/node#{id}/sa-BPEL-NodeNode#{id}-provide.zip", "resources/node#{id}/su-SOAP-NodeService#{id}-consume.zip"


    make_META_INF id
    jbi_sa = NodeCreation.jbi_sa id, children
    open_file_and_write "resources/node#{id}/META-INF/jbi.xml", jbi_sa

    cd "resources/node#{id}/"
    zip "sa-BPEL-NodeNode#{id}-provide.zip", "META-INF"
    cd "../.."




    rm_rf "resources/node#{id}/META-INF"
  end

  def open_file_and_write file_name, content
    file = File.new(file_name, "w")
    file.puts content
    file.close
  end

  def make_META_INF id
    mkdir_p "resources/node#{id}/META-INF"
  end
  
  def zip zip_file, *args
    list = args.join " "
    `zip -qr0m #{zip_file} #{list} 2>/dev/null`
  end
  
  def zip_j zip_file, *args
    list = args.join " "
    `zip -qr0mj #{zip_file} #{list} 2>/dev/null`
  end
end
