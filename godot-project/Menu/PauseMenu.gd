extends Control

var parent

func _on_ButtonPlay_pressed():
	parent.resume_game()

func _on_ButtonSettings_pressed():
	parent.show_settings()

func _on_ButtonQuit_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Menu/TitleScreen.tscn")
