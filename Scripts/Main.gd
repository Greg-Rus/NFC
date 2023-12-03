extends Node2D

func _ready():
	GameManager.init(self)
	GameManager.load_environemnt()
