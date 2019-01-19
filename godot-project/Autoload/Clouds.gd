extends Node2D

var scene_cloud = preload("res://Well/Cloud/Cloud.tscn")

func _ready():
#	create_clouds()
	pass

func create_clouds(amount = 5):
	for i in range(amount):
		var cloud = scene_cloud.instance()
		add_child(cloud)
