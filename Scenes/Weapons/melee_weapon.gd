extends Node2D

@onready var model : MaleeWeaponModel = $SwordModel
var isAttacking : bool

func _ready():
	EventBus.attack_action.connect(on_attack_action)

func _on_area_2d_body_entered(body):
	if(isAttacking):
		var direation_to_body : Vector2 = body.position - global_position
		direation_to_body = direation_to_body.normalized() * model.hit_force
		var damage : int = model.get_updated_damage_table()[Constants.DAMAGE_TABLE.DAMAGE]
		var enemy : Enemy = body as Enemy
		enemy.take_damage(damage, direation_to_body)
		EventBus.enemy_hit.emit()

func on_attack_action(is_attacking):
	isAttacking = is_attacking
