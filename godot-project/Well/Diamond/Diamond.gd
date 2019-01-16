extends Area2D
tool

export var active = false setget set_active

func set_active(value):
	if not has_node("Sprite"): return
	
	active = value
	
	if value == true:
		$Sprite.frame = 1
	else:
		$Sprite.frame = 0