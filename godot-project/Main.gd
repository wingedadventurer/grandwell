extends Node

var scene_camera = preload("res://Camera/Camera.tscn")

func _ready():
#	Engine.time_scale = 0.2
	print("Game started!")
	
	var camera = scene_camera.instance()
	add_child(camera)
	
	Menu.load_title()
	Menu.show()
	
func _process(delta):
	if Input.is_action_just_pressed("quit"):
		Menu.toggle()
