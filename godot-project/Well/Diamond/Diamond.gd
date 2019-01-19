extends Area2D
tool

export var active = false setget set_active
onready var init_active = active

func set_active(value):
	if not has_node("Sprite"): return
	
	active = value
	
	if value == true:
		$Sprite.frame = 0
	else:
		$Sprite.frame = 1

func toggle_active():
	set_active(!active)
	$Toggle.pitch_scale = 0.95 + (randi() % 4) * 0.5
	$Toggle.play()
	
	Get.level().check_diamonds()

func deactivate():
	$Collision.disabled = true
	$Tween.interpolate_property(self, "modulate:a", modulate.a, 0.2, 1.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

func reset():
	set_active(init_active)
	$Collision.disabled = false
	modulate.a = 1.0
