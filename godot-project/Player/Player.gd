extends KinematicBody2D

var scene_bomb = preload("res://Bomb/Bomb.tscn")

enum State {
	Normal,
	Climbing
}

var MAXIMUM_HORIZONTAL_VELOCITY = 200.0 #400.0
var HORIZONTAL_ACCELERATION_ON_GROUND = 1500.0 #3000.0
var HORIZONTAL_DECELERATION_ON_GROUND = 3000.0 #6000.0

var MAXIMUM_VERTICAL_VELOCITY = 450.0 #900.0
var JUMP_STRENGTH = 275.0 #550.0
var GRAVITY_ACCELERATION_DOWN = 1500.0 #3000.0
var GRAVITY_ACCELERATION_UP = 725.0 #1450.0
var COYOTE_TIME = 0.06
var GRAB_DELAY = 0.1

var CLIMB_SPEED = 100.0 #200.0

var velocity = Vector2()
var default_position
var on_floor_last = false
var jump_time = 0.0
onready var state = State.Normal
onready var state_next = State.Normal
var grab_delay = 0.0

func _ready():
	default_position = position

func _process(delta):
	if Input.is_action_just_pressed("reset"):
		position = default_position
		velocity = Vector2()
		state_next = State.Normal
	
	if Input.is_action_just_pressed("player_use"):
		drop_bomb()

func _physics_process(delta):
	# states
	match state:
		State.Normal: state_normal(delta)
		State.Climbing: state_climbing(delta)
	switch_states()

func state_normal(delta):
	# calculating horizontal velocity
	if Input.is_action_pressed("player_move_left"):
		velocity.x -= HORIZONTAL_ACCELERATION_ON_GROUND * delta
		$Sprite.scale.x = abs($Sprite.scale.x) * -1
	elif Input.is_action_pressed("player_move_right"):
		velocity.x += HORIZONTAL_ACCELERATION_ON_GROUND * delta
		$Sprite.scale.x = abs($Sprite.scale.x)
	else:
		var deceleration_amount = HORIZONTAL_DECELERATION_ON_GROUND * delta
		if abs(velocity.x) >= deceleration_amount:
			velocity.x -= deceleration_amount * sign(velocity.x)
		else:
			velocity.x = 0
	
	# limiting horizontal velocity
	velocity.x = clamp(velocity.x, -MAXIMUM_HORIZONTAL_VELOCITY, MAXIMUM_HORIZONTAL_VELOCITY)
	
	# calculating coyote time
	if is_on_floor(): jump_time = COYOTE_TIME
	else:
		if jump_time > 0.0: jump_time -= delta
	
	# calculating grab delay
	if grab_delay > 0.0: grab_delay -= delta
	
	# calculating vertical velocity - applying gravity
	# (varied based on current vertical velocity)
	if velocity.y <= 0 and Input.is_action_pressed("player_jump"): velocity.y += GRAVITY_ACCELERATION_UP * delta
	else: velocity.y += GRAVITY_ACCELERATION_DOWN * delta
	
	# calculating vertical velocity - jumping
	if Input.is_action_just_pressed("player_jump"):
		if is_on_floor():
			if Input.is_action_pressed("player_move_down"):
				position.y += 1
				grab_delay = GRAB_DELAY
#				$Drop.play() # also plays when on ordinary floor!
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
					state_next = State.Climbing
					position.x = ladder.position.x
					break

func state_climbing(delta):
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
		state_next = State.Normal
	
	if Input.is_action_just_pressed("player_jump"):
		if not Input.is_action_pressed("player_move_down"):
			jump(JUMP_STRENGTH)
		state_next = State.Normal

func switch_states():
	if state != state_next:
		match state_next:
			State.Normal:
				grab_delay = GRAB_DELAY
			State.Climbing:
				velocity = Vector2()
		state = state_next

func jump(var strength):
	velocity.y = -strength
	$Jump.play()
	jump_time = 0.0

func drop_bomb():
	var bomb = scene_bomb.instance()
	bomb.position = position
	get_parent().add_child(bomb)
	$BombDrop.play()
