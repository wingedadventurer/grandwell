extends HBoxContainer

onready var label_action = $Label_ActionName
onready var label_binding = $Label_CurrentBinding

var action
var parent

signal rebind

func set_action(value):
	label_action.text = value

func set_binding(value):
	label_binding.text = value

func _rebind_pressed():
	emit_signal("rebind", action)
