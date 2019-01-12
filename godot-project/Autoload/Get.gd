extends Node

func camera():
	var nodes = get_tree().get_nodes_in_group("camera")
	return nodes[0]

func player():
	var nodes = get_tree().get_nodes_in_group("player")
	return nodes[0]
