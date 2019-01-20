extends Area2D
tool

export var active = false setget set_active
onready var init_active = active

func _ready():
	randomize()

func set_active(value):
	if not has_node("Sprite"): return
	
	active = value
	
	if value == true:
		if Engine.editor_hint: $Sprite.frame = 4
		else: $Animations.play("toggle_on")
	else:
		if Engine.editor_hint: $Sprite.frame = 0
		else: $Animations.play("toggle_off")

func toggle_active():
	set_active(!active)
	$Toggle.pitch_scale = 0.95 + (randi() % 4) * 0.5
	$Toggle.play()
	
	Get.level().check_diamonds()

func deactivate():
	$Collision.disabled = true
	$Animations.play("deactivate")

func reset():
	set_active(init_active)
	$Collision.disabled = false
