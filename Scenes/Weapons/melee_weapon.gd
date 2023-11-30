extends Node2D

@export var hit_force : float = 50
var isAttacking : bool

func _on_area_2d_body_entered(body):
	if(isAttacking):
		var rb = body as RigidBody2D
		var direation_to_body = body.position - global_position
		rb.apply_impulse(direation_to_body.normalized() * hit_force)
	if "take_damage" in body:
		body.take_damage(1)

func _on_weapon_slot_root_attack_action(is_attacking):
	isAttacking = is_attacking
