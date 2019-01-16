extends Node2D

export (int) var number # Which level are we currently playing?

const STATE_DESCENT = 0
const STATE_ESCAPE = 1

var scene_player = preload("res://Player/Player.tscn")

var scene_ladder = preload("res://Well/Ladder/Ladder.tscn")
var scene_platform = preload("res://Well/Platform/Platform.tscn")

var state

func _ready():
	print("Well \"" + str(name) + "\" Started!")
	spawn_player()
	$PlayerSpawn.visible = false
	state = STATE_DESCENT
	add_collisions()

func reset():
	state = STATE_DESCENT
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

func begin_escape():
	if state != STATE_ESCAPE:
		print("Escape phase started")
		state = STATE_ESCAPE

func player_escaped():
	if state == STATE_ESCAPE:
		print("Level complete")
		LevelLoader.advance_level(number)
