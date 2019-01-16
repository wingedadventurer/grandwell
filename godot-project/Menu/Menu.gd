extends Node

onready var title = $TitleMenu
onready var settings = $SettingsMenu
onready var level_select = $LevelSelectMenu

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
	for next in [title, settings, level_select]:
		next.parent = self