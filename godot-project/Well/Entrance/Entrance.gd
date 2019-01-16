extends Area2D

# This is the point to which the player must return during
# the escape phase to end the level.

func player_escaped():
	Get.level().player_escaped()

func _body_entered(body):
	# Since only the player occupies the third collision layer,
	# we assume this will only be called when they've reached
	# the entrance.
	player_escaped()