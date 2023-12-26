extends CanvasLayer
class_name UI_Canvas

@onready var hearts_layout : HBoxContainer = $Control/MarginContainer/HBoxContainer
@onready var full_heart_icon = preload("res://Scenes/UI/ui_heart_full.tscn")
@onready var empty_heart_icon = preload("res://Scenes/UI/ui_heart_empty.tscn")

func _ready() -> void:
	EventBus.player_health_changed.connect(on_player_heath_change)
	
func on_player_heath_change():
	hearts_layout.get_children().map(func(child): child.queue_free())
	var heartCount = GameManager.player.hit_points_current
	var emptyHeartCount = GameManager.player.hit_points_max - GameManager.player.hit_points_current
	for i in heartCount:
		var icon = full_heart_icon.instantiate()
		hearts_layout.add_child(icon)
	for i in emptyHeartCount:
		var icon = empty_heart_icon.instantiate()
		hearts_layout.add_child(icon)
	print("Full: " + str(heartCount) +" Empty: " +str(emptyHeartCount))
