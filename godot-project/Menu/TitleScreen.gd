extends Node

onready var title = $CanvasLayer/TitleMenu
onready var settings = $CanvasLayer/SettingsMenu
onready var level_select = $CanvasLayer/LevelSelectMenu

func show_title():
	title.show()
	level_select.hide()
	settings.hide()

func show_level_select():
	title.hide()
	level_select.show()
	settings.hide()

func show_settings():
	title.hide()
	level_select.hide()
	settings.show()

func _ready():
	$TitleBackground.visible = true
	MusicPlayer.play_menu()
	for next in [title, settings, level_select]:
		next.parent = self
