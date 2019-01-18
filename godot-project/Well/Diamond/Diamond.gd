extends Area2D
tool

export var active = false setget set_active

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
	modulate.a = 0.2
