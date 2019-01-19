extends Node2D

export (int) var number # Which level are we currently playing?

var scene_player = preload("res://Player/Player.tscn")
const scene_camera = preload("res://Camera/Camera.tscn")

var scene_ladder = preload("res://Well/Ladder/Ladder.tscn")
var scene_platform = preload("res://Well/Platform/Platform.tscn")
var scene_spikes = load("res://Well/Spikes/Spikes.tscn")

const scene_pause = preload("res://Menu/PauseScreen.tscn")
const scene_levelcomplete = preload("res://Menu/LevelComplete.tscn")


onready var well_center = $WellCenter

var state

enum State {
	DESCENT,
	DISCOVERY,
	ASCENT
}

func _ready():
	print("Well \"" + str(name) + "\" Started!")
	spawn_camera()
	add_collisions()
	$PlayerSpawn.visible = false
	
	reset()

func reset():
	spawn_player()
	state = State.DESCENT
	MusicPlayer.play_descent()
	
	# Reset all 'resettables'
	var resettables = get_tree().get_nodes_in_group("resettables")
	for current_resettable in resettables:
		current_resettable.reset()
	
	# Remove all 'removables'
	var removables = get_tree().get_nodes_in_group("removables")
	for removable in removables:
		removable.queue_free()
	
	Get.camera().pan_down()
	Get.camera().indicator_target = get_bottom_position()
	
	$WaterLine.visible = false

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

func spawn_camera():
	var camera = scene_camera.instance()
	add_child(camera)

func spawn_player():
	var player = scene_player.instance()
	player.position = $PlayerSpawn.position
	add_child(player)
	Get.camera().set_target_player()

func get_top_position():
	return $Top.position

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
	
	for tile in $Spikes.get_used_cells():
		var inst = scene_spikes.instance()
		inst.position = $Spikes.map_to_world(tile) + Vector2(6, 6)
		$Collisions.add_child(inst)

func begin_discovery():
	print("Discovery phase started")
	state = State.DISCOVERY
	MusicPlayer.play_discovery()
	Get.camera().remove_pan()
	Get.camera().indicator_target = null
	Get.camera().set_zoom_amount(0.5)
	Get.camera().set_target_point(well_center)

func begin_escape():
	print("Ascent phase started")
	state = State.ASCENT
	MusicPlayer.play_ascent()
	Get.camera().pan_up()
	Get.camera().indicator_target = get_top_position()
	Get.camera().set_zoom_amount(0.3)
	Get.camera().set_target_player()
	$WaterLine.rising = true
	$WaterLine.show()

func player_escaped():
	print("Level complete")
	MusicPlayer.stop()
	Get.camera().indicator_target = null
	var level_complete = scene_levelcomplete.instance()
	level_complete.level_number = number
	add_child(level_complete)

func player_dead():
	$Timer_Respawn.start()

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

func _on_Timer_Respawn_timeout():
	$Timer_Respawn.stop()
	reset()
