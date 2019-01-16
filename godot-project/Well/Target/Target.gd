extends Area2D

# Obviously, we don't want to begin the escape phase more than once;
# this variable makes sure we only send the signal once
onready var triggered = false

# This will be replaced by a puzzle the player has to solve, but for now,
# it serves as a way of testing the transition between descent and escape.

func begin_escape():
	if not triggered:
		Get.level().begin_escape()
		triggered = true

func _body_entered(body):
	# Since only the bomb occupies the second collision layer,
	# we assume this will only be called when a bomb is dropped
	# into the target.
	begin_escape()

func reset():
	triggered = false