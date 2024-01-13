extends CanvasLayer
class_name UI_Canvas

@onready var hearts_layout : HBoxContainer = %hp_heart_container
@onready var score_label : Label = %level
@onready var xp_progress_bar : TextureProgressBar = %xp_progress_bar
@onready var stamina_bar : TextureProgressBar = %stamina_bar
@onready var axe_indicator : Control = %Axe_Indicator
@onready var ui_root : Control = $UI_Layout

@onready var full_heart_icon = preload("res://Scenes/UI/ui_heart_full.tscn")
@onready var empty_heart_icon = preload("res://Scenes/UI/ui_heart_empty.tscn")

var viewport_center : Vector2
var viewport_padded : Vector2
@export var camera : Camera2D

func _ready() -> void:
	EventBus.player_HP_changed.connect(on_player_heath_change)
	EventBus.XP_changed.connect(on_player_xp_changed)
	EventBus.level_changed.connect(on_level_change)
	EventBus.stamina_changed.connect(on_stamina_changed)
	EventBus.ranged_attack.connect(on_ranged_attack)
	EventBus.axe_position.connect(on_axe_position_change)
	viewport_center = camera.get_viewport_rect().size * 0.5
	viewport_padded = camera.get_viewport_rect().size - Vector2(20,20)
	axe_indicator.visible = true
	
func on_player_heath_change(current_HP : int, max_HP : int):
	hearts_layout.get_children().map(func(child): child.queue_free())
	var emptyHeartCount = max_HP - current_HP
	for i : int in current_HP:
		var icon : Control = full_heart_icon.instantiate() as Control
		hearts_layout.add_child(icon)
	for i in emptyHeartCount:
		var icon : Control = empty_heart_icon.instantiate() as Control
		hearts_layout.add_child(icon)
	
func on_player_xp_changed(xp : int, max_xp: int):
	var progress : float = float(xp) / max_xp
	xp_progress_bar.value = progress
	
func on_level_change(level : int):
	score_label.text = str(level)
	
func on_stamina_changed(current_stamina: float, max_stamina : float):
	stamina_bar.value = current_stamina / max_stamina
	
func on_ranged_attack(in_progress : bool):
	pass
	if(!in_progress):
		axe_indicator.visible = false
	
func on_axe_position_change(position : Vector2):
	update_axe_indicator(position)
	
func update_axe_indicator(global_axe_position : Vector2):
	#Used the tutorial on https://code.tutsplus.com/positioning-on-screen-indicators-to-point-to-off-screen-targets--gamedev-6644t
	var t = camera.get_canvas_transform()
	var to_axe_viewport = t * global_axe_position
	var to_axe = to_axe_viewport - viewport_center
	
	if(is_out_of_screen(to_axe)):
		axe_indicator.visible = true
		var indicator_position : Vector2 = Vector2.ZERO
		var slope = to_axe.y/to_axe.x
		if(to_axe.y < 0): #top
			var y = viewport_padded.y * -0.5
			var x = y / slope
			indicator_position = Vector2(x,y)
		elif(to_axe.y > 0): #bottom
			var y = viewport_padded.y * 0.5
			var x = y / slope
			indicator_position = Vector2(x, y)
		
		if(indicator_position.x < viewport_padded.x * -0.5): #left
			var x = viewport_padded.x * -0.5
			var y = x * slope
			indicator_position = Vector2(x, y)
		elif (indicator_position.x > viewport_padded.x * 0.5): #right
			var x = viewport_padded.x * 0.5
			var y = x * slope
			indicator_position = Vector2(x, y)
			
		axe_indicator.position = indicator_position + viewport_center
		
	else:
		axe_indicator.visible = false

func is_out_of_screen(screen_position : Vector2):
	return screen_position.x < (viewport_center.x * -1) || \
	screen_position.x > viewport_center.x || \
	screen_position.y < (viewport_center.y * -1) || \
	screen_position.y > viewport_center.y
	
