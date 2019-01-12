tool
extends StaticBody2D

export (String, "LeftStart", "Left", "Center", "Right", "RightStart") var type = "Center" setget set_type

func set_type(value):
	if not has_node("Sprite"): return
	
	type = value
	if type == "LeftStart": $Sprite.frame = 0
	elif type == "Center": $Sprite.frame = 1 + randi() % 2
	elif type == "RightStart": $Sprite.frame = 3
	elif type == "Right": $Sprite.frame = 5
	elif type == "Left": $Sprite.frame = 4
