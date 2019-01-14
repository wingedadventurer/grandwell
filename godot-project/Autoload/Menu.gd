extends Node

var scene_title_menu = preload("res://Menu/TitleMenu.tscn")
var scene_level_select_menu = preload("res://Menu/LevelSelectMenu.tscn")
var scene_settings_menu = preload("res://Menu/SettingsMenu.tscn")

var visible = true

func clear_screen():
	for menu in get_tree().get_nodes_in_group("menu"):
		menu.queue_free()

func hide():
	for menu in get_tree().get_nodes_in_group("menu"):
		menu.visible = false
		visible = false
		get_tree().paused = false

func show():
	for menu in get_tree().get_nodes_in_group("menu"):
		menu.visible = true
		visible = true
		get_tree().paused = true

func toggle():
	if visible: hide()
	else: show()

func load_title():
	clear_screen()
	var menu = scene_title_menu.instance()
	$"/root/Main/Display".add_child(menu)

func load_level_select():
	clear_screen()
	var menu = scene_level_select_menu.instance()
	$"/root/Main/Display".add_child(menu)

func load_settings():
	clear_screen()
	var menu = scene_settings_menu.instance()
	$"/root/Main/Display".add_child(menu)
