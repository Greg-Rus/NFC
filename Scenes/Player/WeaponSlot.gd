extends Node2D
class_name WeaponSlot

@onready var animationPlayer : AnimationPlayer = $WeaponSlot/AnimationPlayer
@onready var weaponSlot : Node2D = $WeaponSlot

var isForwardAttack : bool = true
var isAttacking : bool

func _process(delta):
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
	EventBus.attack_action.emit(is_attacking)
