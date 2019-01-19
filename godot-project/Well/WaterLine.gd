extends Polygon2D

const RISE_SPEED = 25

var rising = false

onready var start_pos = global_position

func reset():
	global_position = start_pos
	rising = false
	$Timer_Damage.stop()

func _process(delta):
	if rising:
		position.y -= RISE_SPEED * delta

func _body_entered(body):
	body.hurt()
	$Audio_Splash.play()
	$Timer_Damage.start()

func _body_exited(body):
	$Audio_LeaveWater.play()
	$Timer_Damage.stop()

# Recurring damage if the player remains in water
func _on_Timer_Damage_timeout():
	Get.player().hurt()

func show():
	visible = true
	$Tween.interpolate_property(self, "modulate:a", 0.0, 1.0, 2.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
