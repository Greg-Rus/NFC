extends Node2D

@onready var model : MaleeWeaponModel = $SwordModel
var isAttacking : bool

func _ready():
	EventBus.melee_attack.connect(on_melee_attack)

func _on_area_2d_body_entered(body):
	if(isAttacking):
		var direation_to_body : Vector2 = body.position - global_position
		direation_to_body = direation_to_body.normalized() * model.hit_force
		var enemy : Enemy = body as Enemy
		enemy.take_damage(model.get_updated_damage_table(), direation_to_body)
		EventBus.enemy_hit_melee.emit()

func on_melee_attack(is_attacking):
	isAttacking = is_attacking
