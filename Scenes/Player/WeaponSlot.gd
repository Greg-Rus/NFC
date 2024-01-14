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

func _ready():
	attack_zone_top.rotation = deg_to_rad(weapon.model.weapon_arc_degrees * -0.5)
	attack_zone_bottom.rotation = deg_to_rad(weapon.model.weapon_arc_degrees * 0.5)

func _process(_delta):
	if(Input.is_action_just_pressed("attack")):
		if(!animationPlayer.is_playing()):
			if(isForwardAttack):
				animationPlayer.play("SwordOberhau")
			else:
				animationPlayer.play("SwordUnterhau")
			isForwardAttack = !isForwardAttack
			set_is_attacking(true)
			
func set_weapon_rotation(angle: float):
	if(!isAttacking):
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
			weapon.deal_damage_to_enemy(enemy)
