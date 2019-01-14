extends Camera2D

var PAN_AMOUNT = 80.0
var PAN_TIME = 1.0
var PLAYER_HORIZONTAL_FOLLOW_LERP_WEIGHT = 0.15
var PLAYER_HORIZONTAL_FOLLOW_PARALLAX_FACTOR = 0.6
var PLAYER_VERTICAL_FOLLOW_LERP_WEIGHT = 0.05

#var offset_screenshake = Vector2() #TODO

func _ready():
	pan_down()

func _process(delta):
	# follow player
	var player = Get.player()
	if player != null:
		position.x = lerp(position.x, player.position.x * PLAYER_HORIZONTAL_FOLLOW_PARALLAX_FACTOR, PLAYER_HORIZONTAL_FOLLOW_LERP_WEIGHT)
		position.y = lerp(position.y, player.position.y, PLAYER_VERTICAL_FOLLOW_LERP_WEIGHT)
	print(player)
	
	# pan with up and down keys (TEMP)
#	if Input.is_action_just_pressed("player_move_up"): pan_up()
#	elif Input.is_action_just_pressed("player_move_down"): pan_down()

func pan_down():
	$Tween.interpolate_property(self, "offset:y", offset.y, PAN_AMOUNT, PAN_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()

func pan_up():
	$Tween.interpolate_property(self, "offset:y", offset.y, -PAN_AMOUNT, PAN_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
