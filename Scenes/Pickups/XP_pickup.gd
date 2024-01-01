extends BasePickup
class_name XP_Pickup

var spawn_position : Vector2
var experience : int = 1

func picked_up():
	spawn_position = global_position
	var tween = get_tree().create_tween()
	tween.tween_method(move_to_player, 0.0, 1.0, 0.3)
	tween.tween_callback(on_arrival)

func move_to_player(t : float):
	global_position = lerp(spawn_position, player.global_position, t)
	
func on_arrival():
	player.pickup_XP(experience)
	queue_free()
