extends Area2D
class_name Axe

@onready var sprite : Sprite2D = $Sprite2D
@onready var model : MaleeWeaponModel = $SwordModel
@export var speed : float
@export var rotation_speed : float

var player : Player
var throw_direction : Vector2
var is_recalled : bool
var is_thrown : bool
var velocity : Vector2

func _physics_process(delta : float):
	if(!is_thrown):
		return
	
	update_velocity(delta)
	move()
	
func _process(delta : float):
	sprite.rotate(rotation_speed * delta)

func throw(direction : Vector2, throwing_player : Player) -> void:
	throw_direction = direction
	player = throwing_player
	is_thrown = true
	EventBus.stamina_drain.emit(model.stamina_cost)
	
func recall():
	EventBus.stamina_drain.emit(model.stamina_cost)
	is_recalled = true
	
func update_velocity(delta : float):
	if(!is_recalled):
		velocity = throw_direction * speed * delta
	else:
		var vector_to_player = player.global_position - global_position
		if(vector_to_player.length() < 2):
			player.on_axe_returned()
		else:
			velocity = vector_to_player.normalized() * speed * delta
		
func move():
	global_position = global_position + velocity

func _on_body_entered(body):
	var enemy = body as Enemy
	enemy.take_damage(model.get_updated_damage_table(), velocity.normalized())
	EventBus.enemy_hit_ranged.emit()
