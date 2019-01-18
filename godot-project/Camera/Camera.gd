extends Camera2D

var PLAYER_HORIZONTAL_FOLLOW_LERP_WEIGHT = 0.15
var PLAYER_HORIZONTAL_FOLLOW_PARALLAX_FACTOR = 0.6
var PLAYER_VERTICAL_FOLLOW_LERP_WEIGHT = 0.05

var INDICATOR_CHECK_OFFSET_HEIGHT = 12.0

var MINIMUM_DEPTH = 0.0
var DEPTH_SCALE = 50.0
var MINIMUM_DARKNESS_AMOUNT = 0.0
var MAXIMUM_DARKNESS_AMOUNT = 0.8
var MINIMUM_REVERB_AMOUNT = 0.0
var MAXIMUM_REVERB_AMOUNT = 0.3
var REVERB_FACTOR = 0.5

# pan
var PAN_AMOUNT = 40.0
var PAN_TIME = 1.0
var pan_offset = Vector2()

# screen shake
var DEFAULT_SHAKE_TIME = 0.5
var DEFAULT_SHAKE_STRENGTH = 10.0
var shake_time = 0.0
var shake_strength = 1.0
var shake_offset = Vector2()

var indicator_target = null

func _process(delta):
	var level = Get.level()
	var player = Get.player()
	
	# depth indicator position
	if level != null and player != null:
		$DepthIndicator.visible = true
		var viewport_size = get_viewport_rect().size * zoom
		var check_height = viewport_size.y * 0.5 - INDICATOR_CHECK_OFFSET_HEIGHT
		indicator_target = level.get_bottom_position()
		
		$DepthIndicator.position = to_local(indicator_target)
		if indicator_target.y > global_position.y + offset.y + check_height:
			$DepthIndicator.position.y = offset.y + check_height
			$DepthIndicator/Label.text = str(get_remaining_depth()).pad_decimals(0) + "m\nv"
		elif indicator_target.y < global_position.y + offset.y - check_height:
			$DepthIndicator.position.y = offset.y - check_height + 20.0
			$DepthIndicator/Label.text = "^\n" + str(get_remaining_depth()).pad_decimals(0)
		else:
			$DepthIndicator/Label.text = str(get_remaining_depth()).pad_decimals(0) + "m"
	else:
		$DepthIndicator.visible = false
	
	# follow player
	if player != null:
		position.x = lerp(position.x, player.position.x * PLAYER_HORIZONTAL_FOLLOW_PARALLAX_FACTOR, PLAYER_HORIZONTAL_FOLLOW_LERP_WEIGHT)
		position.y = lerp(position.y, player.position.y, PLAYER_VERTICAL_FOLLOW_LERP_WEIGHT)
	
	# shake camera
	if shake_time > 0:
		shake_offset = Vector2(1, 1).rotated(deg2rad(rand_range(0, 360.0))) * shake_time * shake_strength
		shake_time -= delta
	
	apply_depth_effects()
	
	print(shake_offset)
	offset = pan_offset + shake_offset

func shake(time = DEFAULT_SHAKE_TIME, strength = DEFAULT_SHAKE_STRENGTH):
	shake_time = time
	shake_strength = strength

func apply_depth_effects():
	var level = Get.level()
	if level == null:
		return
	
	var depth_scale = 0.0
	
	var total_depth = level.get_bottom_position().y / 24
	var remaining_depth = get_remaining_depth()
	var current_depth = total_depth - remaining_depth
	
	if current_depth >= MINIMUM_DEPTH:
		depth_scale = (current_depth - MINIMUM_DEPTH) / DEPTH_SCALE
	
	# applying darkness
	var darkness_amount = clamp(depth_scale, MINIMUM_DARKNESS_AMOUNT, MAXIMUM_DARKNESS_AMOUNT)
	level.modulate = Color(1 - darkness_amount, 1 - darkness_amount, 1 - darkness_amount)
	
	# applying reverb
	var reverb_amount = clamp(depth_scale, MINIMUM_REVERB_AMOUNT, MAXIMUM_REVERB_AMOUNT)
	AudioServer.get_bus_effect(AudioServer.get_bus_index("SFX"), 0).wet = (reverb_amount) * REVERB_FACTOR

func get_remaining_depth():
	var level = Get.level()
	var player = Get.player()
	if level == null or player == null: return
	var start = player.global_position
	var end = level.get_bottom_position()
	
	var distance = end.y - start.y
	return distance / 24

func pan_down():
	$Tween.interpolate_property(self, "pan_offset:y", pan_offset.y, PAN_AMOUNT, PAN_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()

func pan_up():
	$Tween.interpolate_property(self, "pan_offset:y", pan_offset.y, -PAN_AMOUNT, PAN_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()

func remove_pan():
	$Tween.interpolate_property(self, "pan_offset:y", pan_offset.y, 0, PAN_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
