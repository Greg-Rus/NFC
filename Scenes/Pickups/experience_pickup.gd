extends Node2D
class_name ExperiencePickup
@onready var collision_shape : CollisionShape2D = $Area2D/CollisionShape2D
var spawn_position : Vector2
var experience : int = 1
var player : Player

func _on_area_2d_body_entered(body):
	spawn_position = global_position
	player = body as Player
	
	var tween = get_tree().create_tween()
	tween.tween_method(move_to_player, 0.0, 1.0, 0.3)
	tween.tween_callback(on_arrival)

func move_to_player(t : float):
	global_position = lerp(spawn_position, player.global_position, t)
	
func on_arrival():
	player.pickup_XP(experience)
	queue_free()
