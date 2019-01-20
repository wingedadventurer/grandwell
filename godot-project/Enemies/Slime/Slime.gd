extends KinematicBody2D

var JUMP_STRENGTH = 200.0
var JUMP_DELAY_MIN = 1.0
var JUMP_DELAY_MAX = 2.0
var GRAVITY_ACCELERATION = 1400.0
var jump_delay = 0.0
var HORIZONTAL_MOVE_SPEED = 100.0
var HORIZONTAL_DISTANCE_CHECK = 30.0

var velocity = Vector2()

enum State {
	IDLE,
	MOVING,
	DEAD
}

var state = State.MOVING

func _ready():
	$Animations.play("idle")
	jump_delay = rand_range(JUMP_DELAY_MIN, JUMP_DELAY_MAX)

func _physics_process(delta):
	match state:
		State.IDLE: state_idle(delta)
		State.MOVING: state_moving(delta)
		State.DEAD: state_dead(delta)
	
	if velocity.x > 0: $Sprite.scale.x = 1
	elif velocity.x < 0: $Sprite.scale.x = -1

func change_state(new_state):
	if state == new_state: return
	match new_state:
		State.IDLE:
			velocity = Vector2()
			$Animations.play("idle")
		State.MOVING:
			$Animations.play("move")
		State.DEAD:
			$Animations.play("die")
	state = new_state

func state_idle(delta):
	jump_delay -= delta
	if jump_delay <= 0.0:
		jump()

func state_moving(delta):
	if not is_on_floor(): velocity.y += GRAVITY_ACCELERATION * delta
	move(delta)
	
	if is_on_floor(): change_state(State.IDLE)

func state_dead(delta):
	if not is_on_floor(): velocity.y += GRAVITY_ACCELERATION * delta
	move(delta)

func move(delta):
	# horizontal
	var velocity_old = velocity
	velocity.x = move_and_slide(Vector2(velocity.x, 0), Vector2(0, -1)).x
	if velocity.x != velocity_old.x:
		HORIZONTAL_MOVE_SPEED *= -1
		velocity.x = velocity_old.x * -1
	
	# vertical
	velocity.y = move_and_slide(Vector2(0, velocity.y), Vector2(0, -1)).y

func jump():
	velocity.x = HORIZONTAL_MOVE_SPEED
	velocity.y = -JUMP_STRENGTH
	change_state(State.MOVING)
	jump_delay = rand_range(JUMP_DELAY_MIN, JUMP_DELAY_MAX)
	
	var collision = test_move(transform, Vector2(HORIZONTAL_DISTANCE_CHECK * sign(velocity.x), 0))
	if collision:
		velocity.x *= -1
		HORIZONTAL_MOVE_SPEED *= -1
		collision = test_move(transform, Vector2(HORIZONTAL_DISTANCE_CHECK * sign(velocity.x), 0))
		if collision:
			velocity.x = 0

func hurt():
	change_state(State.DEAD)

func _on_Animations_animation_finished(anim_name):
	if anim_name == "die": queue_free()
