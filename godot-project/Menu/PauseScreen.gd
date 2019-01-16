extends CanvasLayer

onready var pause_menu = $PauseMenu
onready var settings = $SettingsMenu

func show_title():
	pause_menu.show()
	settings.hide()

func show_settings():
	pause_menu.hide()
	settings.show()

func resume_game():
	get_tree().paused = false
	queue_free()

func _ready():
	get_tree().paused = true
	for next in [pause_menu, settings]:
		next.parent = self