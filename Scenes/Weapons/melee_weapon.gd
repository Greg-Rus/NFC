extends Node2D
class_name Weapon

@onready var model : MaleeWeaponModel = $SwordModel
var isAttacking : bool

func _ready():
	EventBus.melee_attack.connect(on_melee_attack)
		
func deal_damage_to_enemy(enemy : Enemy):
	var direation_to_enemy : Vector2 = enemy.position - global_position
	var hit_force_vector = direation_to_enemy.normalized() * model.hit_force
	enemy.take_damage(model.get_updated_damage_table(), hit_force_vector)

func on_melee_attack(is_attacking):
	if(is_attacking):
		EventBus.stamina_drain.emit(model.stamina_cost)
	isAttacking = is_attacking
