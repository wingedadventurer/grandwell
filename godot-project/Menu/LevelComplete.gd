extends CanvasLayer

var level_number

func _ready():
	get_tree().paused = true
	$Audio_LevelClear.play()

func _on_Button_Next_pressed():
	get_tree().paused = false
	LevelLoader.advance_level(level_number)
 