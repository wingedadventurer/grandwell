extends RigidBody2D

func reset():
	# Assuming that the only bombs in the level are ones dropped by the player,
	# (i.e. ones that aren't present when the level starts), we want them to
	# disappear when the level is reset
	queue_free()