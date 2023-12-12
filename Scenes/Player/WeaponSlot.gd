extends Node2D

@onready var animationPlayer : AnimationPlayer = $WeaponSlot/AnimationPlayer
@onready var weaponSlot : Node2D = $WeaponSlot
signal attack_action(is_attacking : bool)
signal hit_ark_transition(in_hit_ark: bool)

var isForwardAttack : bool = true
var isAttacking : bool
var is_in_ark: bool
var weapon_ark_degrees: float = 90

func _draw():
	draw_line(position, position + transform.basis_xform(Vector2(20,0)) , Color.RED, 2)

func _process(delta):
	if(Input.is_action_just_pressed("attack")):
		if(!animationPlayer.is_playing()):
			if(isForwardAttack):
				animationPlayer.play("SwordOberhau")
			else:
				animationPlayer.play("SwordUnterhau")
			isForwardAttack = !isForwardAttack
			set_is_attacking(true)
	if(isAttacking):
		if(weaponSlot.rotation_degrees > -weapon_ark_degrees and weaponSlot.rotation_degrees < weapon_ark_degrees && not is_in_ark):
			is_in_ark = true;
			hit_ark_transition.emit(is_in_ark)
			queue_redraw()
		elif((weaponSlot.rotation_degrees < -weapon_ark_degrees or weaponSlot.rotation_degrees > weapon_ark_degrees) && is_in_ark):
			is_in_ark = false;
			hit_ark_transition.emit(is_in_ark)
			queue_redraw()
		
			
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
	attack_action.emit(is_attacking)
