extends Area2D
class_name BasePickup

@onready var collision_shape : CollisionShape2D = $CollisionShape2D
var player : Player

func _on_body_entered(body):
	collision_shape.disabled = true
	player = body as Player
	picked_up()

func picked_up():
	push_warning("!@# Base Pickup has no override with handling logic")
