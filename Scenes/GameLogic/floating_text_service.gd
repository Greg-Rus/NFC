extends Node2D

var floating_text_scene : Resource
func _ready():
	floating_text_scene = preload("res://Scenes/Feedbacks/floating_text.tscn")
	EventBus.damage_taken.connect(spawn_floating_text)

func spawn_floating_text(damage_table, spawn_position: Vector2) -> void:
	var new_floating_text = floating_text_scene.instantiate() as Node2D
	new_floating_text.global_position = spawn_position
	add_child(new_floating_text)
	var offset = Vector2(randi_range(-10, 10) * 2, -10 - randi_range(5, 10))
	new_floating_text.init(str(damage_table[Constants.DAMAGE_TABLE.DAMAGE]), offset, damage_table[Constants.DAMAGE_TABLE.IS_CRIT])
