extends Node2D

var scene_player = preload("res://Player/Player.tscn")

var scene_ladder = preload("res://Well/Ladder/Ladder.tscn")
var scene_platform = preload("res://Well/Platform/Platform.tscn")

func _ready():
	print("Well \"" + str(name) + "\" Started!")
	spawn_player()
	$PlayerSpawn.visible = false
	
	add_collisions()

func reset():
	# Reset all 'resettables'
	var resettables = get_tree().get_nodes_in_group("resettables")
	for current_resettable in resettables:
		current_resettable.reset()

func spawn_player():
	var player = scene_player.instance()
	player.position = $PlayerSpawn.position
	add_child(player)

func get_bottom_position():
	return $Bottom.global_position

func add_collisions():
	for tile in $Ladders.get_used_cells():
		var inst = scene_ladder.instance()
		inst.position = $Ladders.map_to_world(tile) + Vector2(12, 6)
		$Collisions.add_child(inst)
	
	for tile in $Platforms.get_used_cells():
		var inst = scene_platform.instance()
		inst.position = $Platforms.map_to_world(tile)
		$Collisions.add_child(inst)
