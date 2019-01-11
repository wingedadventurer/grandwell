extends KinematicBody2D

var MAXIMUM_HORIZONTAL_VELOCITY = 500.0
var HORIZONTAL_ACCELERATION_ON_GROUND = 4000.0
var HORIZONTAL_DECELERATION_ON_GROUND = 6000.0
var JUMP_IMPULSE_VELOCITY_STRENGTH = 700.0
var GRAVITY_ACCELERATION = 3000.0
#var GRAVITY_ACCELERATION_DOWN = 3000.0
#var GRAVITY_ACCELERATION_UP = 2000.0

var velocity
var default_position
var on_floor_last

func _ready():
	velocity = Vector2()
	default_position = position
	on_floor_last = false

func _process(delta):
	if Input.is_action_just_pressed("reset"):
		position = default_position
		velocity = Vector2()

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
	
	velocity.x = clamp(velocity.x, -MAXIMUM_HORIZONTAL_VELOCITY, MAXIMUM_HORIZONTAL_VELOCITY)

	# calculating vertical velocity - applying gravity
	velocity.y += GRAVITY_ACCELERATION * delta
	
	# calculating vertical velocity - applying gravity (varied based on vertical velocity)
	# TODO
#	if velocity.y > 0: velocity.y += GRAVITY_ACCELERATION_DOWN * delta
#	else: velocity.y += GRAVITY_ACCELERATION_UP * delta
	
	# calculating vertical velocity - jumping
	if Input.is_action_just_pressed("player_jump"):
		if is_on_floor():
			if Input.is_action_pressed("player_move_down"):
				position.y += 1
				$Drop.play() # also plays when on ordinary floor!
			else:
				velocity.y = -JUMP_IMPULSE_VELOCITY_STRENGTH
				$Jump.play()
	
	# moving
	velocity = move_and_slide(velocity, Vector2(0, -1))
	if on_floor_last != is_on_floor():
		if on_floor_last == false:
			$Land.play()
		on_floor_last = is_on_floor()
