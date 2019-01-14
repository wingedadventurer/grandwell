extends Node

var levels = {
	1: "res://Levels/LevelTest.tscn"
}

func clear_levels():
	for level in get_tree().get_nodes_in_group("level"):
		level.queue_free()

func load_level(number):
	clear_levels()
	var scene_level = load(levels[number])
	var level = scene_level.instance()
	Get.main().add_child(level)
	Menu.load_title()
	Menu.hide()
	MusicPlayer.play_descent()
