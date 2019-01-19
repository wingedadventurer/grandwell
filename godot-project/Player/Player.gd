extends KinematicBody2D

var scene_laserbeam = preload("res://Player/LaserBeam/LaserBeam.tscn")
const scene_playercorpse = preload("res://Player/PlayerCorpse.tscn")

enum State {
	NORMAL,
	CLIMBING,
	SHOOTING
}

# horizontal movement
var MAXIMUM_HORIZONTAL_VELOCITY = 200.0
var HORIZONTAL_ACCELERATION_ON_GROUND = 1500.0
var HORIZONTAL_ACCELERATION_IN_AIR = 400.0
var HORIZONTAL_DECELERATION_ON_GROUND = 3000.0
var HORIZONTAL_DECELERATION_IN_AIR = 200.0

# vertical movement
var MAXIMUM_VERTICAL_VELOCITY = 450.0
var JUMP_STRENGTH = 275.0
var GRAVITY_ACCELERATION_DOWN = 1500.0
var GRAVITY_ACCELERATION_UP = 725.0
var COYOTE_TIME = 0.06
var GRAVITY_SCALE_DEFAULT = 1.0
var gravity_scale

# climbing
var GRAB_DELAY = 0.1
var CLIMB_SPEED = 100.0

# jumping
var jump_start_y = 0 	# For the sake of determining if we take fall damage,
						# we note our y position when we jumped,
						# so we can compare it to the y position when we land

const MAX_SAFE_FALL_DISTANCE = 140

# shooting
var SHOOT_TIME = 0.5
var SHOOT_SLOWMO_AMOUNT = 0.2

const MAX_HEALTH = 3

onready var health = MAX_HEALTH
var invulnerable = false

# animation
var lock_animation = false

var velocity = Vector2()
var default_position
var on_floor_last = false
var jump_time = 0.0
onready var state = State.NORMAL
onready var state_next = State.NORMAL
var grab_delay = 0.0
var shoot_time = 0.0
var laser_beam_rotation = Vector2(1, 0)

func _ready():
	default_position = position
	gravity_scale = GRAVITY_SCALE_DEFAULT
#	var camera = scene_camera.instance()
#	get_parent().add_child(camera)

func _process(delta):
	if Input.is_action_just_pressed("reset"):
		die()
#		position = default_position
#		velocity = Vector2()
#		state_next = State.NORMAL
#		health = MAX_HEALTH
#		# Tell the level that we want to reset
#		Get.level().reset()
	
	choose_laserbeam_direction()
	update()

func _physics_process(delta):
	# states
	match state:
		State.NORMAL: state_normal(delta)
		State.CLIMBING: state_climbing(delta)
		State.SHOOTING: state_shooting(delta)
	switch_states()

func _draw():
	if state == State.SHOOTING:
		draw_line(Vector2(), laser_beam_rotation * 20.0, Color(1, 0.2, 0.2, 0.5), 3.0)
		draw_circle(Vector2(), shoot_time * 30.0 + 10.0, Color(1.0, 0.2, 0.2, 0.5))

func state_normal(delta):
	# calculating horizontal velocity
	var acceleration_amount
	var deceleration_amount
	if is_on_floor():
		acceleration_amount = HORIZONTAL_ACCELERATION_ON_GROUND * delta
		deceleration_amount = HORIZONTAL_DECELERATION_ON_GROUND * delta
	else:
		acceleration_amount = HORIZONTAL_ACCELERATION_IN_AIR * delta
		deceleration_amount = HORIZONTAL_DECELERATION_IN_AIR * delta
	if Input.is_action_pressed("player_move_left"):
		if velocity.x > -MAXIMUM_HORIZONTAL_VELOCITY:
			velocity.x -= acceleration_amount
		$Sprite.scale.x = abs($Sprite.scale.x) * -1
		if not lock_animation and $Movement.current_animation != "walk": $Movement.play("walk")
	elif Input.is_action_pressed("player_move_right"):
		if velocity.x < MAXIMUM_HORIZONTAL_VELOCITY:
			velocity.x += acceleration_amount
		$Sprite.scale.x = abs($Sprite.scale.x)
		if not lock_animation and $Movement.current_animation != "walk": $Movement.play("walk")
	else:
		if abs(velocity.x) >= deceleration_amount:
			velocity.x -= deceleration_amount * sign(velocity.x)
		else:
			velocity.x = 0
		if not lock_animation and $Movement.current_animation != "stand": $Movement.play("stand")
	
	# animating if not on floor
	if not is_on_floor():
		if velocity.y <= 0: $Movement.play("jump")
		else: $Movement.play("fall")
	
	# jump start y
	if is_on_floor() or velocity.y < 0:
		jump_start_y = position.y
	
	# calculating coyote time
	if is_on_floor(): jump_time = COYOTE_TIME
	else:
		if jump_time > 0.0: jump_time -= delta
	
	# calculating grab delay
	if grab_delay > 0.0: grab_delay -= delta
	
	# calculating vertical velocity - applying gravity
	# (varied based on current vertical velocity)
	if velocity.y <= 0 and Input.is_action_pressed("player_jump"): velocity.y += GRAVITY_ACCELERATION_UP * gravity_scale * delta
	else: velocity.y += GRAVITY_ACCELERATION_DOWN * gravity_scale * delta
	
	# calculating vertical velocity - jumping
	if Input.is_action_just_pressed("player_jump"):
		if is_on_floor():
			if Input.is_action_pressed("player_move_down"):
				position.y += 1
				grab_delay = GRAB_DELAY
			else:
				jump(JUMP_STRENGTH)
		elif jump_time > 0.0: jump(JUMP_STRENGTH)
	
	# limiting vertical velocity
	velocity.y = clamp(velocity.y, -MAXIMUM_VERTICAL_VELOCITY, MAXIMUM_VERTICAL_VELOCITY)
	
	# moving
	velocity = move_and_slide(velocity, Vector2(0, -1))
	if on_floor_last != is_on_floor():
		if on_floor_last == false:
			$Land.play()
			if not lock_animation:
				land()
		on_floor_last = is_on_floor()
	
	# checking ladders
	if (Input.is_action_pressed("player_move_up")) and grab_delay <= 0.0:
		var top_check = false
		for ladder in $LadderCheckUp.get_overlapping_areas():
			if ladder.is_in_group("ladder"):
				top_check = true
				break
		if top_check:
			for ladder in $LadderCheckDown.get_overlapping_areas():
				if ladder.is_in_group("ladder"):
					state_next = State.CLIMBING
					position.x = ladder.position.x
					break
	
	# SHOOTING
	if Input.is_action_just_pressed("player_shoot") and can_shoot():
		state_next = State.SHOOTING

func state_climbing(delta):
	jump_start_y = position.y
	# calculating velocity (climb if there is more ladder)
	velocity.y = 0
	if Input.is_action_pressed("player_move_up"):
		for area in $LadderCheckUp.get_overlapping_areas():
			if area.is_in_group("ladder"):
				velocity.y -= CLIMB_SPEED
	if Input.is_action_pressed("player_move_down"):
		for area in $LadderCheckDown.get_overlapping_areas():
			if area.is_in_group("ladder"):
				velocity.y += CLIMB_SPEED
	
	# applying velocity
	var collision = move_and_collide(velocity * delta)
	if collision != null:
		velocity = Vector2()
		state_next = State.NORMAL
	
	if Input.is_action_just_pressed("player_jump"):
		if not Input.is_action_pressed("player_move_down"):
			jump(JUMP_STRENGTH)
		state_next = State.NORMAL
	
	# SHOOTING
	if Input.is_action_just_pressed("player_shoot") and can_shoot():
		state_next = State.SHOOTING

func state_shooting(delta):
	# shoot countdown
	if shoot_time >= 0: shoot_time -= delta
	if shoot_time < 0 or Input.is_action_just_released("player_shoot"):
		shoot()
		shoot_time = 0
		state_next = State.NORMAL
	
	# applying gravity
	if velocity.y <= 0: velocity.y += GRAVITY_ACCELERATION_UP * gravity_scale * delta
	else: velocity.y += GRAVITY_ACCELERATION_DOWN * gravity_scale * delta
	
	# moving
	velocity = move_and_slide(velocity, Vector2(0, -1))
	if on_floor_last != is_on_floor():
		on_floor_last = is_on_floor()

func choose_laserbeam_direction():
	if Input.is_action_just_pressed("player_move_right"):
		if Input.is_action_pressed("player_move_up"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(315))
		elif Input.is_action_pressed("player_move_down"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(45))
		else: laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(0))
	if Input.is_action_just_pressed("player_move_down"):
		if Input.is_action_pressed("player_move_left"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(135))
		elif Input.is_action_pressed("player_move_right"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(45))
		else: laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(90))
	if Input.is_action_just_pressed("player_move_left"):
		if Input.is_action_pressed("player_move_up"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(225))
		elif Input.is_action_pressed("player_move_down"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(135))
		else: laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(180))
	if Input.is_action_just_pressed("player_move_up"):
		if Input.is_action_pressed("player_move_left"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(225))
		elif Input.is_action_pressed("player_move_right"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(315))
		else: laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(270))

func choose_laserbeam_direction_tick():
	if Input.is_action_pressed("player_move_right"):
		if Input.is_action_pressed("player_move_up"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(315))
		elif Input.is_action_pressed("player_move_down"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(45))
		else: laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(0))
	if Input.is_action_pressed("player_move_down"):
		if Input.is_action_pressed("player_move_left"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(135))
		elif Input.is_action_pressed("player_move_right"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(45))
		else: laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(90))
	if Input.is_action_pressed("player_move_left"):
		if Input.is_action_pressed("player_move_up"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(225))
		elif Input.is_action_pressed("player_move_down"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(135))
		else: laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(180))
	if Input.is_action_pressed("player_move_up"):
		if Input.is_action_pressed("player_move_left"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(225))
		elif Input.is_action_pressed("player_move_right"): laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(315))
		else: laser_beam_rotation = Vector2(1, 0).rotated(deg2rad(270))


func switch_states():
	if state != state_next:
		match state_next:
			State.NORMAL:
				grab_delay = GRAB_DELAY
				gravity_scale = GRAVITY_SCALE_DEFAULT
			State.CLIMBING:
				velocity = Vector2()
				gravity_scale = GRAVITY_SCALE_DEFAULT
			State.SHOOTING:
				velocity *= SHOOT_SLOWMO_AMOUNT
				gravity_scale = SHOOT_SLOWMO_AMOUNT
				shoot_time = SHOOT_TIME
				choose_laserbeam_direction_tick()
				$Charge.play()
		state = state_next

func can_shoot():
	return true # TODO: add shoot delay

func shoot():
	var laserbeam = scene_laserbeam.instance()
	laserbeam.global_position = global_position
	
	laserbeam.rotation = laser_beam_rotation.angle()
	var throw = Vector2(1, 0).rotated(laser_beam_rotation.angle() + deg2rad(180)) * 500.0
	velocity = throw
	
	Get.level().add_child(laserbeam)
	$Charge.stop()
	$Shot.play()
	Get.camera().shake()

func jump(var strength):
	velocity.y = -strength
	$Jump.play()
	jump_time = 0.0

func land():
	$Movement.play("land")
	lock_animation = true
	var fall_distance = position.y - jump_start_y
	print(fall_distance)
	if fall_distance > MAX_SAFE_FALL_DISTANCE:
		$LegBreak.play()
		hurt()

func hurt():
	health -= 1
	if health > 0:
		invulnerable = true
		$Timer_Invulnerability.start()
	else:
		die()

func die():
	var corpse = scene_playercorpse.instance()
	corpse.global_position = global_position
	corpse.apply_impulse(Vector2(0, 0), Vector2(0, -100))
	get_parent().add_child(corpse)
	Get.camera().set_target_point(corpse)
	Get.level().player_dead()
	queue_free()

func _on_Movement_animation_finished(anim_name):
	lock_animation = false

func _on_Timer_Invulnerability_timeout():
	invulnerable = false
