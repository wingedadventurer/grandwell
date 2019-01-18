extends Node

var levels = {
	1: {
		"scene": "res://Levels/LevelTest.tscn",
		"next_level": 2
	},
	2: {
		"scene": "res://Levels/Level2.tscn",
		"next_level": null
	}
}

func get_level_scene(number):
	return levels[number]["scene"]

func get_next_level_number(number):
	return levels[number]["next_level"]

func load_level(number):
	MusicPlayer.stop()
	var scene_path = get_level_scene(number)
	get_tree().change_scene(scene_path)

func advance_level(number):
	var next_level = get_next_level_number(number)
	load_level(next_level)
