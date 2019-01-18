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
	add_collisions()
	state = State.DESCENT
	MusicPlayer.play_descent()
	Get.camera().pan_down()

func reset():
	state = State.DESCENT
	# Reset all 'resettables'
	var resettables = get_tree().get_nodes_in_group("resettables")
	for current_resettable in resettables:
		current_resettable.reset()
	
	Get.camera().pan_down()

func check_diamonds():
	if state != State.DISCOVERY: return
	
	for diamond in $Diamonds.get_children():
		if diamond.is_in_group("diamond") and\
		diamond.active == false: return false
	
	deactivate_diamonds()
	begin_escape()

func deactivate_diamonds():
	for diamond in $Diamonds.get_children():
		if diamond.is_in_group("diamond"):
			diamond.deactivate()

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
	print("Discovery phase started")
	state = State.DISCOVERY
	MusicPlayer.play_discovery()
	Get.camera().remove_pan()

func begin_escape():
	print("Ascent phase started")
	state = State.ASCENT
	MusicPlayer.play_ascent()
	Get.camera().pan_up()

func player_escaped():
	print("Level complete")
	LevelLoader.advance_level(number)
	MusicPlayer.stop()

func _process(delta):
	if Input.is_action_pressed("pause"):
		var pause = scene_pause.instance()
		add_child(pause)

func _on_DescentCheck_body_entered(body):
	if body.is_in_group("player") and state == State.DESCENT:
		begin_discovery()

func _on_AscentCheck_body_entered(body):
	if body.is_in_group("player") and state == State.ASCENT:
		player_escaped()