extends Node2D

@export var hit_force : float = 50
var isAttacking : bool

func _on_area_2d_body_entered(body):
	if(isAttacking):
		var direation_to_body : Vector2 = body.position - global_position
		direation_to_body = direation_to_body.normalized() * hit_force
		var enemy = body as Enemy
		enemy.take_damage(1, direation_to_body)

func _on_weapon_slot_root_attack_action(is_attacking):
	isAttacking = is_attacking
