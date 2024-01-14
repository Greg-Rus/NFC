extends Line2D

@export var target : Node2D
@export var point_count : int = 10
@export var point_spawn_frequency : float = 0.5

var spawn_time : float = 0

func _ready():
	pass
	top_level = true
	
func _process(delta):
	if(spawn_time <= 0):
		add_point(target.global_position)
		if(points.size() > point_count):
			remove_point(0)
		spawn_time = point_spawn_frequency
	else:
		spawn_time -= delta
