extends Control

func _on_ButtonBack_pressed():
	Menu.load_title()

func _on_Level1_pressed():
	LevelLoader.load_level(1)
