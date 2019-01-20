extends Area2D

var LIFETIME = 0.5
var has_checked = false
var length = 1.0

func _ready():
	$Tween.interpolate_property(self, "modulate:a", modulate.a, 0.0, LIFETIME, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	
	var diff = length - 24.0
	if diff > 0.0:
		$SpriteEnd.position.x += diff
		$SpriteMid.visible = true
		$SpriteMid.scale.x = (1.0 / 12.0) * diff
		
	$Collision.scale.x = (1.0 / 12.0) * (24.0 + diff)
	$Collision.position.x = -6.0 + 6.0 * $Collision.scale.x

func _physics_process(delta):
	if not has_checked:
		has_checked = true
		
		for area in get_overlapping_areas():
			if area.is_in_group("diamond"):
				area.toggle_active()
		
		for body in get_overlapping_bodies():
			if body.is_in_group("hurtable"):
				body.hurt()

func _on_Tween_tween_completed(object, key):
	queue_free()
