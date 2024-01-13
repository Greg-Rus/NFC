extends Node2D

var camera : Camera2D

func _ready():
	camera = %MainCamera
	GameManager.main_camera = camera
	
	GameManager.init(self)
	GameManager.load_environemnt()
