extends Control

var parent

func _on_ButtonBack_pressed():
	parent.show_title()

func _on_Level1_pressed():
	LevelLoader.load_level(1)

func _on_Level2_pressed():
	LevelLoader.load_level(2)

func _on_Level3_pressed():
	LevelLoader.load_level(3)

func _on_Level4_pressed():
	LevelLoader.load_level(4)

func _on_Level5_pressed():
	LevelLoader.load_level(5)
