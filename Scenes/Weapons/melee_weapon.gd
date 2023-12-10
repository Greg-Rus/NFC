extends Node2D

@export var hit_force : float = 50
@export var base_damage: int
@export var glance_hit_multiplier: float
@export var crit_hit_multiplier: float
var isAttacking : bool
var hit_candidates : Array
var crit_candidates : Array
var resolved_strikes : Array

func on_hit_zone_enter(body: Node2D) -> void:
	if(not isAttacking or resolved_strikes.has(body)):
		return
		
	hit_candidates.append(body)
	pass	

func on_hit_zone_exit(body: Node2D) -> void:
	if(not isAttacking or not hit_candidates.has(body)): #the crit already was converted to a hit. No extra hit needed.
		return

	if(crit_candidates.has(body)):
		crit_candidates.erase(body)
	
	resolve_hit(body)
	hit_candidates.erase(body)	


func on_crit_zone_enter(body: Node2D) -> void:
	if(not isAttacking or resolved_strikes.has(body)):
		return
		
	crit_candidates.append(body)
	pass

func on_crit_zone_exit(body: Node2D) -> void:
	if(not isAttacking or resolved_strikes.has(body)):
		return
		
	if(hit_candidates.has(body)):
		resolve_hit(body)
		crit_candidates.erase(body)
		hit_candidates.erase(body)
	else:
		resolve_crit(body)
	hit_candidates.erase(body)
	
func resolve_hit(body: Node2D) -> void:
	resolved_strikes.append(body)
	var enemy = body as Enemy
	enemy.take_damage(base_damage, get_normalized_direction_to_hit_body(body))
	
func resolve_crit(body: Node2D) -> void:
	resolved_strikes.append(body)
	var scaled_damage : float = base_damage * crit_hit_multiplier
	var enemy = body as Enemy
	enemy.take_damage(ceili(scaled_damage), get_normalized_direction_to_hit_body(body))
	
func get_normalized_direction_to_hit_body(body: Node2D) -> Vector2:
	return body.position - global_position
	
func _on_weapon_slot_root_attack_action(is_attacking):
	isAttacking = is_attacking
	if(not is_attacking):
		hit_candidates.clear()
		crit_candidates.clear()
		resolved_strikes.clear()
