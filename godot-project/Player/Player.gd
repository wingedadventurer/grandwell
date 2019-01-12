extends KinematicBody2D

var scene_bomb = preload("res://Bomb/Bomb.tscn")

var MAXIMUM_HORIZONTAL_VELOCITY = 500.0
var HORIZONTAL_ACCELERATION_ON_GROUND = 4000.0
var HORIZONTAL_DECELERATION_ON_GROUND = 6000.0

var MAXIMUM_VERTICAL_VELOCITY = 900.0
var JUMP_IMPULSE_VELOCITY_STRENGTH = 550.0
var GRAVITY_ACCELERATION_DOWN = 3000.0
var GRAVITY_ACCELERATION_UP = 1450.0
var COYOTE_TIME = 0.06

var velocity = Vector2()
var default_position
var on_floor_last = false
var coyote_time = 0.0

func _ready():
	default_position = position

func _process(delta):
	if Input.is_action_just_pressed("reset"):
		position = default_position
		velocity = Vector2()
	
	if Input.is_action_just_pressed("player_use"):
		drop_bomb()

func _physics_process(delta):
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
	if is_on_floor(): coyote_time = COYOTE_TIME
	else:
		if coyote_time > 0.0: coyote_time -= delta
	print(coyote_time)
	
	# calculating vertical velocity - applying gravity
	# (varied based on current vertical velocity)
	if velocity.y <= 0 and Input.is_action_pressed("player_jump"): velocity.y += GRAVITY_ACCELERATION_UP * delta
	else: velocity.y += GRAVITY_ACCELERATION_DOWN * delta
	
	# calculating vertical velocity - jumping
	if Input.is_action_just_pressed("player_jump"):
		if is_on_floor():
			if Input.is_action_pressed("player_move_down"):
				position.y += 1
#				$Drop.play() # also plays when on ordinary floor!
			else:
				jump()
		elif coyote_time > 0.0: jump()
	
	# limiting vertical velocity
	velocity.y = clamp(velocity.y, -MAXIMUM_VERTICAL_VELOCITY, MAXIMUM_VERTICAL_VELOCITY)
	
	# moving
	velocity = move_and_slide(velocity, Vector2(0, -1))
	if on_floor_last != is_on_floor():
		if on_floor_last == false:
			$Land.play()
		on_floor_last = is_on_floor()

func jump():
	velocity.y = -JUMP_IMPULSE_VELOCITY_STRENGTH
	$Jump.play()
	coyote_time = 0.0

func drop_bomb():
	var bomb = scene_bomb.instance()
	bomb.position = position
	get_parent().add_child(bomb)
	$BombDrop.play()
