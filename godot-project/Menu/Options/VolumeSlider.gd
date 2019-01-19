extends HBoxContainer

var channel

func _value_changed(value):
	Options.set_channel_volume(channel, value)

func _ready():
	$Label.text = channel
	$HSlider.value = Options.get_channel_volume(channel)
