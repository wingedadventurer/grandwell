extends Area2D

var LIFETIME = 0.5
var has_checked = false
var length = 1.0

func _ready():
	$Tween.interpolate_property(self, "modulate:a", modulate.a, 0.0, LIFETIME, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	
	

func _physics_process(delta):
	if not has_checked:
		has_checked = true
		
		for area in get_overlapping_areas():
			if area.is_in_group("diamond"):
				area.toggle_active()

func _on_Tween_tween_completed(object, key):
	queue_free()
