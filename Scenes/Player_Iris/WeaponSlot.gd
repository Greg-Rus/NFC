extends Node2D

@onready var animationPlayer : AnimationPlayer = $WeaponSlot/AnimationPlayer

var isForwardAttack : bool = true

func _process(delta):
	if(Input.is_action_just_pressed("attack")):
		if(!animationPlayer.is_playing()):
			if(isForwardAttack):
				animationPlayer.play("SwordOberhau")
			else:
				animationPlayer.play_backwards("SwordOberhau")
			isForwardAttack = !isForwardAttack
