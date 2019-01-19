extends Node

const SAVE_PATH = "user://settings.cfg"

const actions = {
	"player_move_left": "Run left",
	"player_move_right": "Run right",
	"player_move_up": "Climb up",
	"player_move_down": "Climb down",
	"player_jump": "Jump",
	"player_shoot": "Shoot",
	"pause": "Pause"
}

var config
var parent

func update_controls():
	for next_action in actions:
		var key = get_key_binding(next_action)
		bind_action(next_action, key)

func bind_action(action, key):
	var event = InputEventKey.new()
	event.scancode = key
	# Remove any old bindings
	for old_event in InputMap.get_action_list(action):
		InputMap.action_erase_event(action, old_event)
	# Add the new one
	InputMap.action_add_event(action, event)

func get_key_binding(action):
	var default = InputMap.get_action_list(action)[0].scancode
	return config.get_value("controls", action, default)

func set_key_binding(action, key):
	config.set_value("controls", action, key)
	bind_action(action, key)

func get_action_label(action):
	return actions[action]

func save_settings():
	config.save(SAVE_PATH)

func get_channel_volume(channel):
	return config.get_value("volume", channel, 1.0)

func update_volumes():
	for current_channel in ["SFX", "Music"]:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(current_channel),
		linear2db(get_channel_volume(current_channel)))

func set_channel_volume(channel, value):
	config.set_value("volume", channel, value)
	update_volumes()

func _enter_tree():
	config = ConfigFile.new()
	config.load(SAVE_PATH)
	update_volumes()
	update_controls()
