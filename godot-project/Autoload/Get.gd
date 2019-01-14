extends Node

func camera():
	var nodes = get_tree().get_nodes_in_group("camera")
	if nodes.size() > 0: return nodes[0]
	else: return null

func player():
	var nodes = get_tree().get_nodes_in_group("player")
	if nodes.size() > 0: return nodes[0]
	else: return null

func main():
	return get_node("/root/Main")
