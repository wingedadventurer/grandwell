extends Node

var levels = {
	1: {
		"scene": "res://Levels/Level01.tscn",
		"next_level": 2
	},
	2: {
		"scene": "res://Levels/Level02.tscn",
		"next_level": 3
	},
	3: {
		"scene": "res://Levels/Level03.tscn",
		"next_level": 4
	},
	4: {
		"scene": "res://Levels/Level04.tscn",
		"next_level": 5
	},
	5: {
		"scene": "res://Levels/Level05.tscn",
		"next_level": null
	}
}

func get_level_scene(number):
	return levels[number]["scene"]
 
func get_next_level_number(number):
	return levels[number]["next_level"]

func load_level(number):
	var scene_path = get_level_scene(number)
	get_tree().call_deferred("change_scene", scene_path)

func advance_level(number):
	var next_level = get_next_level_number(number)
	load_level(next_level)
