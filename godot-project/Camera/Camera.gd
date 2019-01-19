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
var PAN_AMOUNT = 20.0
var PAN_TIME = 1.0
var pan_offset = Vector2()

# screen shake
var DEFAULT_SHAKE_TIME = 0.5
var DEFAULT_SHAKE_STRENGTH = 10.0
var shake_time = 0.0
var shake_strength = 1.0
var shake_offset = Vector2()

# zoom
var zoom_amount_target = 0.33
var zoom_amount_actual = 0.33

enum Targets { PLAYER, POINT }
var target_point = null
var current_target = Targets.PLAYER

var indicator_target = null

func _process(delta):
	var level = Get.level()
	var player = Get.player()
	
	# depth indicator position
	if level != null and player != null and indicator_target != null:
		$DepthIndicator.visible = true
		var viewport_size = get_viewport_rect().size * zoom
		var check_height = viewport_size.y * 0.5 - INDICATOR_CHECK_OFFSET_HEIGHT
		
		$DepthIndicator.position = to_local(indicator_target)
		if indicator_target.y > global_position.y + offset.y + check_height:
			$DepthIndicator.position.y = offset.y + check_height
			$DepthIndicator/Label.text = str(get_remaining_depth()).pad_decimals(0) + "m\nv"
		elif indicator_target.y < global_position.y + offset.y - check_height:
			$DepthIndicator.position.y = offset.y - check_height + 20.0
			$DepthIndicator/Label.text = "^\n" + str(get_remaining_depth()).pad_decimals(0) + "m"
		else:
			$DepthIndicator/Label.text = str(get_remaining_depth()).pad_decimals(0) + "m"
	else:
		$DepthIndicator.visible = false
	
	# follow player
	if current_target == Targets.PLAYER && player != null:
		position.x = lerp(position.x, player.position.x * PLAYER_HORIZONTAL_FOLLOW_PARALLAX_FACTOR, PLAYER_HORIZONTAL_FOLLOW_LERP_WEIGHT)
		position.y = lerp(position.y, player.position.y, PLAYER_VERTICAL_FOLLOW_LERP_WEIGHT)
	elif current_target == Targets.POINT:
		position.x = lerp(position.x, target_point.position.x, 5 * delta)
		position.y = lerp(position.y, target_point.position.y, 5 * delta)
	
	# shake camera
	if shake_time > 0:
		shake_offset = Vector2(1, 1).rotated(deg2rad(rand_range(0, 360.0))) * shake_time * shake_strength
		shake_time -= delta
	
	apply_depth_effects()
	
	# combine pan and screen shake offsets
	offset = pan_offset + shake_offset
	
	# adjust zoom amount
	zoom_amount_actual = lerp(zoom_amount_actual, zoom_amount_target, delta/2)
	zoom.x = zoom_amount_actual
	zoom.y = zoom_amount_actual

func shake(time = DEFAULT_SHAKE_TIME, strength = DEFAULT_SHAKE_STRENGTH):
	shake_time = time
	shake_strength = strength

func apply_depth_effects():
	var level = Get.level()
	var player = Get.player()
	if level == null or player == null:
		return
	
	var depth_scale = 0.0
	
	var current_depth = get_depth() / 24
	
	if current_depth >= MINIMUM_DEPTH:
		depth_scale = (current_depth - MINIMUM_DEPTH) / DEPTH_SCALE
	
	# applying darkness
	var darkness_amount = clamp(depth_scale, MINIMUM_DARKNESS_AMOUNT, MAXIMUM_DARKNESS_AMOUNT)
	level.modulate = Color(1 - darkness_amount, 1 - darkness_amount, 1 - darkness_amount)
	
	# applying reverb
	var reverb_amount = clamp(depth_scale, MINIMUM_REVERB_AMOUNT, MAXIMUM_REVERB_AMOUNT)
	AudioServer.get_bus_effect(AudioServer.get_bus_index("SFX"), 0).wet = (reverb_amount) * REVERB_FACTOR
	
	# fade out sfx with depth
	var sfx_volume = clamp(get_remaining_depth(), 0, 15)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_volume-15)

func get_remaining_depth():
	if indicator_target == null: return 0
	var level = Get.level()
	var player = Get.player()
	if level == null or player == null: return
	var start = player.global_position
	var end = indicator_target
	
	var distance = end.y - start.y
	return abs(distance / 24)

func get_depth():
	var player = Get.player()
	if player == null: return 0
	
	return player.global_position.y

func pan_down():
	$Tween.interpolate_property(self, "pan_offset:y", pan_offset.y, PAN_AMOUNT, PAN_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()

func pan_up():
	$Tween.interpolate_property(self, "pan_offset:y", pan_offset.y, -PAN_AMOUNT, PAN_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()

func remove_pan():
	$Tween.interpolate_property(self, "pan_offset:y", pan_offset.y, 0, PAN_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()

func set_zoom_amount(amount):
	zoom_amount_target = amount

func set_target_player():
	current_target = Targets.PLAYER

func set_target_point(point):
	current_target = Targets.POINT
	target_point = point
