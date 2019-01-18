extends Node2D

export (int) var number # Which level are we currently playing?

var scene_player = preload("res://Player/Player.tscn")

var scene_ladder = preload("res://Well/Ladder/Ladder.tscn")
var scene_platform = preload("res://Well/Platform/Platform.tscn")

const scene_pause = preload("res://Menu/PauseScreen.tscn")

var state

enum State {
	DESCENT,
	DISCOVERY,
	ASCENT
}

func _ready():
	print("Well \"" + str(name) + "\" Started!")
	spawn_player()
	$PlayerSpawn.visible = false
	state = State.DESCENT
	add_collisions()
	MusicPlayer.play_descent()
	
	$AscentCheck/Collision.disabled = true

func reset():
	state = State.DESCENT
	# Reset all 'resettables'
	var resettables = get_tree().get_nodes_in_group("resettables")
	for current_resettable in resettables:
		current_resettable.reset()
	
	$DescentCheck/Collision.disabled = false
	$AscentCheck/Collision.disabled = true

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

func begin_discovery():
	if state != State.DISCOVERY:
		print("Discovery phase started")
		state = State.DISCOVERY
		MusicPlayer.play_discovery()

func begin_escape():
	if state != State.ASCENT:
		print("Ascent  phase started")
		state = State.ASCENT

func player_escaped():
	if state == State.ASCENT:
		print("Level complete")
		LevelLoader.advance_level(number)

func _process(delta):
	if Input.is_action_pressed("pause"):
		var pause = scene_pause.instance()
		add_child(pause)

func _on_DescentCheck_body_entered(body):
	if body.is_in_group("player"):
		begin_discovery()
		$DescentCheck/Collision.disabled = true
		$AscentCheck/Collision.disabled = false

func _on_AscentCheck_body_entered(body):
	if body.is_in_group("player"):
		$AscentCheck/Collision.disabled = true