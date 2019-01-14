extends Camera2D

var PAN_AMOUNT = 80.0
var PAN_TIME = 1.0
var PLAYER_HORIZONTAL_FOLLOW_LERP_WEIGHT = 0.15
var PLAYER_HORIZONTAL_FOLLOW_PARALLAX_FACTOR = 0.6
var PLAYER_VERTICAL_FOLLOW_LERP_WEIGHT = 0.05

var INDICATOR_CHECK_OFFSET_HEIGHT = 20

var target = null

#var offset_screenshake = Vector2() #TODO

func _ready():
	pan_down()

func _process(delta):
	var level = Get.level()
	var player = Get.player()
	
	# depth indicator position
	if level != null and player != null:
		$DepthIndicator.visible = true
		var start = to_local(player.global_position)
		var viewport_size = get_viewport_rect().size
		var check_height = viewport_size.y * 0.5 - INDICATOR_CHECK_OFFSET_HEIGHT
		var well_bottom_position = level.get_bottom_position()

		if well_bottom_position.y < global_position.y + offset.y + check_height:
			$DepthIndicator.position = to_local(well_bottom_position)
			$DepthIndicator/Label.text = str(get_depth()).pad_decimals(0) + "m"
		else:
			var distance = well_bottom_position - global_position
			var angle = distance.angle_to(Vector2(0, 1))
			var x = check_height * tan(angle)
			$DepthIndicator.position = offset + Vector2(x, check_height)
			$DepthIndicator/Label.text = str(get_depth()).pad_decimals(0) + "m\nv"
	else:
		$DepthIndicator.visible = false
	
	# follow player
	if player != null:
		position.x = lerp(position.x, player.position.x * PLAYER_HORIZONTAL_FOLLOW_PARALLAX_FACTOR, PLAYER_HORIZONTAL_FOLLOW_LERP_WEIGHT)
		position.y = lerp(position.y, player.position.y, PLAYER_VERTICAL_FOLLOW_LERP_WEIGHT)
	
	# pan with up and down keys (TEMP)
#	if Input.is_action_just_pressed("player_move_up"): pan_up()
#	elif Input.is_action_just_pressed("player_move_down"): pan_down()

func get_depth():
	var level = Get.level()
	var player = Get.player()
	if level == null or player == null: return
	var start = player.global_position
	var end = level.get_bottom_position()
	
	var distance = end - start
	return distance.length() / 24

func pan_down():
	$Tween.interpolate_property(self, "offset:y", offset.y, PAN_AMOUNT, PAN_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()

func pan_up():
	$Tween.interpolate_property(self, "offset:y", offset.y, -PAN_AMOUNT, PAN_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
