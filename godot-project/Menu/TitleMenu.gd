extends Control

func _on_ButtonPlay_pressed():
	Menu.load_level_select()

func _on_ButtonSettings_pressed():
	Menu.load_settings()

func _on_ButtonQuit_pressed():
	get_tree().quit()
