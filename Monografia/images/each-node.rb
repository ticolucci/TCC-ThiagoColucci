@graph.each_node do |node|
	response << "#{node.name.downcase}='http://localhost/#{node.type}Node#{node.id}'"
end