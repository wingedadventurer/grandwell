extends Node2D

var scene_player = preload("res://Player/Player.tscn")

func _ready():
	print("Well \"" + str(name) + "\" Started!")
	spawn_player()
	$PlayerSpawn.visible = false

func spawn_player():
	var player = scene_player.instance()
	player.position = $PlayerSpawn.position
	add_child(player)

func get_bottom_position():
	return $Bottom.global_position
