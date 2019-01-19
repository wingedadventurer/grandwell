extends Node2D

func _ready():
	randomize()
	get_children()[randi() % get_child_count()].visible = true