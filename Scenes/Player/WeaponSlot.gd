extends Node2D
class_name WeaponSlot

@onready var animationPlayer : AnimationPlayer = $WeaponSlot/AnimationPlayer
@onready var weaponSlot : Node2D = $WeaponSlot
@onready var attack_zone : Area2D = $AttackZone
@onready var weapon : Weapon = $WeaponSlot/Sword

var isForwardAttack : bool = true
var isAttacking : bool

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
	var bodies = attack_zone.get_overlapping_bodies()
	var forward = global_transform.basis_xform(Vector2.RIGHT)

	for enemy : Enemy in bodies:
		var enemy_direction = enemy.global_position - global_position
		var angle_difference_degrees = rad_to_deg(absf(angle_difference(rotation, enemy_direction.angle())))
		if(angle_difference_degrees < weapon.model.weapon_arc_degrees * 0.5):
			weapon.deal_damage_to_enemy(enemy)
