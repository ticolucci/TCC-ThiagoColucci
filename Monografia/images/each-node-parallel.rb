@graph.each_node_parallel do |node|
  set_up_server_for node
  start_petals_on node
  generate_orchestration_of node
end