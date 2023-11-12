extends CharacterBody2D

@export var speed : float = 100

@onready var animationTree : AnimationTree = $AnimationTree
@onready var sprite : Sprite2D = $Sprite2D
@onready var weaponSlot : Node2D = $WeaponSlotRoot

func _physics_process(delta):
	var input = Input.get_vector("left", "right", "up", "down")
	velocity = input * speed 
	var isWalking = input != Vector2.ZERO
	animationTree["parameters/conditions/idle"] = !isWalking
	animationTree["parameters/conditions/walking"] = isWalking
	
	if(input.x != 0):
		sprite.flip_h = input.x < 0
		weaponSlot.scale = Vector2(-1, 1) if input.x < 0 else Vector2(1,1)
		
	move_and_slide()
