extends Line2D
class_name AttackZoneIndicator

@export var point_count : int = 15
var origin : Vector2
var radius : float
var arc : float

func init(center: Vector2, attack_range : float, attack_arc : float):
	origin = center
	radius = attack_range
	arc = attack_arc
	
	var vector : Vector2 = Vector2.RIGHT * radius
	var step : float = deg_to_rad(arc / point_count)
	var current_rotation : float = deg_to_rad(arc * -0.5)
	
	for i : int in range(point_count):
		add_point(vector.rotated(current_rotation))
		current_rotation += step
