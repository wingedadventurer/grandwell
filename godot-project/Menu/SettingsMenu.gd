extends Control

const obj_button = preload("res://Menu/Options/KeyBinder.tscn")
const obj_volume_slider = preload("res://Menu/Options/VolumeSlider.tscn")

onready var label_prompt = $Label_Prompt
onready var vbox_controls = $Center/VBox/VBox_Controls
onready var vbox_volume = $Center/VBox/VBox_Volume

onready var buttons = {}
onready var currently_binding = false

var binding_action
var parent

signal done

func setup_volume():
	for next_channel in ["SFX", "Music"]:
		var slider = obj_volume_slider.instance()
		slider.channel = next_channel
		vbox_volume.add_child(slider)

func setup_buttons():
	for next_action in Options.actions:
		var scancode = Options.get_key_binding(next_action)
		# Create the button
		var button = obj_button.instance()
		vbox_controls.add_child(button)
		button.set_action(Options.actions[next_action])
		button.set_binding(OS.get_scancode_string(scancode))
		button.action = next_action
		button.connect("rebind", self, "start_rebinding")
		buttons[next_action] = button

func start_rebinding(action):
	#audio_selected.play()
	label_prompt.text = "Press key for '%s'" % Options.actions[action]
	binding_action = action
	currently_binding = true

func rebind_action(action, key):
	# Find the button that corresponds to this control, and update it
	var button = buttons[action]
	button.set_binding(key.as_text())
	# Update the Options singleton
	Options.set_key_binding(action, key.scancode)
	# We're done; stop rebinding keys until the user wants to rebind another action
	currently_binding = false
	label_prompt.text = ""

func _input(event):
	if event is InputEventKey:
		if currently_binding:
			get_tree().set_input_as_handled()
			rebind_action(binding_action, event)

func _on_ButtonBack_pressed():
	Options.save_settings()
	parent.show_title()

func _ready():
	setup_volume()
	setup_buttons()