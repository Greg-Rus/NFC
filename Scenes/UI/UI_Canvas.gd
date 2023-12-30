extends CanvasLayer
class_name UI_Canvas

@onready var hearts_layout : HBoxContainer = $Control/MarginContainer/HBoxContainer
@onready var score_label : Label = $Control/MarginContainer/Score
@onready var full_heart_icon = preload("res://Scenes/UI/ui_heart_full.tscn")
@onready var empty_heart_icon = preload("res://Scenes/UI/ui_heart_empty.tscn")

func _ready() -> void:
	EventBus.player_HP_changed.connect(on_player_heath_change)
	EventBus.XP_changed.connect(on_player_xp_changed)
	
func on_player_heath_change(current_HP : int, max_HP : int):
	hearts_layout.get_children().map(func(child): child.queue_free())
	var emptyHeartCount = max_HP - current_HP
	for i : int in current_HP:
		var icon : Control = full_heart_icon.instantiate() as Control
		hearts_layout.add_child(icon)
	for i in emptyHeartCount:
		var icon : Control = empty_heart_icon.instantiate() as Control
		hearts_layout.add_child(icon)
	
func on_player_xp_changed(xp : int):
	score_label.text = str(xp)
