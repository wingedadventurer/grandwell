extends Control

var parent

func _on_ButtonBack_pressed():
	parent.show_title()

func _on_Level1_pressed():
	LevelLoader.load_level(1)
