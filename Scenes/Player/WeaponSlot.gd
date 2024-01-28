extends Node2D
class_name WeaponSlot

@onready var animationPlayer : AnimationPlayer = $WeaponSlot/AnimationPlayer
@onready var weaponSlot : Node2D = $WeaponSlot
@onready var attack_zone_arc : Area2D = %AttackZoneArc
@onready var attack_zone_top : Area2D = %AttackZoneEdgeTop
@onready var attack_zone_bottom : Area2D = %AttackZoneEdgeBottom
@onready var weapon : Weapon = $WeaponSlot/Sword

var isForwardAttack : bool = true
var isAttacking : bool
var is_spinning : bool = false
var accumulated_spin : float

func _ready():
	attack_zone_top.rotation = deg_to_rad(weapon.model.weapon_arc_degrees * -0.5)
	attack_zone_bottom.rotation = deg_to_rad(weapon.model.weapon_arc_degrees * 0.5)

func _process(delta):
	if(Input.is_action_just_pressed("attack") && !is_spinning):
		if(!animationPlayer.is_playing()):
			if(isForwardAttack):
				animationPlayer.play("SwordOberhau")
			else:
				animationPlayer.play("SwordUnterhau")
			isForwardAttack = !isForwardAttack
			set_is_attacking(true)
			
	if(Input.is_action_just_pressed("spin")):
		if(GameManager.player.model.current_rage >= weapon.model.spin_rage_cost):
			EventBus.rage_drain.emit(weapon.model.spin_rage_cost)
			animationPlayer.play("spin")
			is_spinning = true
			set_is_attacking(true)
			GameManager.player.on_spin_start()
		
	if(Input.is_action_just_released("spin")):
		is_spinning = false
		
	if(is_spinning || accumulated_spin > 0): #even if input is over, complete the spin
		process_spin(delta)
		
func can_spin() -> bool:
	return GameManager.player.model.current_rage >= weapon.model.spin_rage_cost && is_spinning
		
func stop_spin():
		animationPlayer.play("RESET")
		is_spinning = false
		accumulated_spin = 0
		
		set_is_attacking(false)
		
func process_spin(delta : float) -> void:
	var rotation_delta = TAU / weapon.model.spin_duration_seconds * delta
	accumulated_spin += rotation_delta
	if(accumulated_spin >= TAU):
		evaluate_spin_hit()
		if(can_spin()):
			EventBus.rage_drain.emit(weapon.model.spin_rage_cost)
		else:
			stop_spin()
		accumulated_spin = 0
		
	rotate(rotation_delta)
	if(rotation > PI):
		rotation = -PI
		
func evaluate_spin_hit():
	for enemy in attack_zone_arc.get_overlapping_bodies():
		deal_damage(enemy)
			
func set_weapon_rotation(angle: float) -> void:
	if(!isAttacking && !is_spinning):
		rotation = angle
		
	if(weaponSlot.global_rotation > -3 && weaponSlot.global_rotation < 0):
		weaponSlot.z_index = -1
	else:
		weaponSlot.z_index = 1

func on_attack_animation_done():
	set_is_attacking(false)
	
func set_is_attacking(is_attacking: bool):
	isAttacking = is_attacking
	EventBus.melee_attack.emit(is_attacking)

func attack_apex_reached():
	var enemies = {}
	
	for e in attack_zone_top.get_overlapping_bodies():
		if(!enemies.has(e)):
			enemies[e] = e
	
	for e in attack_zone_bottom.get_overlapping_bodies():
		if(!enemies.has(e)):
			enemies[e] = e

	for e in attack_zone_arc.get_overlapping_bodies():
		if(enemies.has(e)):
			continue
		var enemy_direction = e.global_position - global_position
		var angle_difference_degrees = rad_to_deg(absf(angle_difference(rotation, enemy_direction.angle())))
		if(angle_difference_degrees < weapon.model.weapon_arc_degrees * 0.5):
			enemies[e] = e
			
	for enemy : Enemy in enemies.keys():
			deal_damage(enemy, true)
			
			
func deal_damage(enemy : Enemy, should_generat_range : bool = false) -> void:
	var damage_table = weapon.deal_damage_to_enemy(enemy)
	if(should_generat_range):
		var rage = damage_table[Constants.DAMAGE_TABLE.DAMAGE] * weapon.model.damage_to_rage_ratio
		EventBus.rage_gain.emit(rage)
