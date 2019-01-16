extends Control

var parent

func _on_ButtonPlay_pressed():
	parent.show_level_select()

func _on_ButtonSettings_pressed():
	parent.show_settings()

func _on_ButtonQuit_pressed():
	get_tree().quit()
