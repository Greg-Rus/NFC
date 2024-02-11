extends Node2D
class_name DashTrail

@export var sprites : Array[Sprite2D] = []
@export var character_sprite : Sprite2D
@export var start_color : Color
var next_index : int = 0
var last_shown_index : int = -1
var update_interval : float
var tweens : Array[Tween] = []

func _ready():
	update_interval = 1 / sprites.size()
	for sprite in sprites:
		sprite.visible = false
		
func start():
	next_index = 0
	for sprite in sprites:
		sprite.visible = false
	for t in tweens:
		if(t.is_running()):
			t.kill()
	tweens.clear()

func update(progress : float) -> void:
	if(progress >= update_interval * next_index):
		show_next_sprite()
	
func show_next_sprite():
	if(next_index > sprites.size() - 1):
		push_warning("DashTrail sprite array index out of bounds!")
		return
	var sprite = sprites[next_index]
	sprite.global_position = global_position
	sprite.visible = true
	sprite.frame = character_sprite.frame
	sprite.flip_h = character_sprite.flip_h
	sprite.modulate = start_color
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color.TRANSPARENT, 0.3).set_ease(Tween.EASE_IN)
	tweens.append(tween)
	next_index = next_index + 1
