extends Node2D

func _process(delta):
	$Path2D/PathFollow2D.offset += delta * 25