extends Area2D
class_name Axe

@onready var sprite : Sprite2D = $axe_mask
@onready var model : MaleeWeaponModel = $SwordModel
@export var speed : float
@export var rotation_speed : float

var player : Player
var throw_direction : Vector2
var is_recalled : bool
var is_thrown : bool
var velocity : Vector2
var origin : Vector2
var grounded : bool = false

func _physics_process(delta : float):
	if(!is_thrown):
		return
	
	update_velocity(delta)
	move()
	
func _process(delta : float):
	EventBus.axe_position.emit(global_position)
	if(grounded):
		return
	sprite.rotate(rotation_speed * delta)

func throw(direction : Vector2, throwing_player : Player) -> void:
	origin = global_position
	throw_direction = direction
	player = throwing_player
	is_thrown = true
	EventBus.stamina_drain.emit(model.stamina_cost)
	
func recall():
	grounded = false
	EventBus.stamina_drain.emit(model.stamina_cost)
	is_recalled = true
	sprite.self_modulate = Color.TRANSPARENT
	sprite.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
	
func update_velocity(delta : float):
	var vector_to_player = player.global_position - global_position
	
	if(vector_to_player.length() < 10 && (grounded || is_recalled)):
		player.on_axe_returned()
		
	if(grounded):
		velocity = Vector2.ZERO
	elif(!is_recalled):
		velocity = throw_direction * speed * delta
	else:
		velocity = vector_to_player.normalized() * speed * delta

func move():
	global_position = global_position + velocity
	var distance_from_origin = (origin - global_position).length()
	if(!is_recalled && distance_from_origin > model.range):
		grounded = true
		sprite.rotation_degrees = 135
		sprite.self_modulate = Color.WHITE
		sprite.clip_children = CanvasItem.CLIP_CHILDREN_ONLY

func _on_body_entered(body):
	if(grounded):
		return
	var enemy = body as Enemy
	enemy.take_damage(model.get_updated_damage_table(), velocity.normalized())
	EventBus.enemy_hit_ranged.emit()
