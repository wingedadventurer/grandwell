extends Sprite

var scene_slime = preload("res://Enemies/Slime/Slime.tscn")

func _ready():
	visible = false

func reset():
	spawn_slime()

func spawn_slime():
	var slime = scene_slime.instance()
	Get.level().add_child(slime)
	slime.global_position = global_position
