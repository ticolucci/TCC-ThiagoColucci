@graph.each_node do |node|
	response << "xmlns:#{node.name.downcase}=\"http://localhost/#{node.type}Node#{node.id}\" "
end