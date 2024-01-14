class_name Player
extends CharacterBody2D

@onready var animationTree : AnimationTree = $AnimationTree
@onready var sprite : Sprite2D = $Sprite2D
@onready var weaponSlot : WeaponSlot = $WeaponSlotRoot
@onready var axe_scene = preload("res://Scenes/Weapons/axe.tscn")
@onready var camera_remote : RemoteTransform2D = %CameraRemote
@onready var attack_zone_indicator : AttackZoneIndicator = $AttackZoneIndicator

var model : PlayerModel

var isFlipped : bool = false
var invincibility_timer : Timer
var hit_tween : Tween
var directionToPointer : Vector2
var isWalking : bool
var input : Vector2
var axe : Axe

func _ready():
	model = %Model
	invincibility_timer = Timer.new()
	invincibility_timer.one_shot = true
	add_child(invincibility_timer)	
	camera_remote.remote_path = GameManager.main_camera.get_path()
	attack_zone_indicator.init(weaponSlot.position, weaponSlot.weapon.model.range, weaponSlot.weapon.model.weapon_arc_degrees)
	
func _process(_delta):
	input = Input.get_vector("left", "right", "up", "down")
	isWalking = input != Vector2.ZERO
	animationTree["parameters/conditions/idle"] = !isWalking
	if(Input.is_action_just_pressed("Throw")):
		on_throw_action()

func _physics_process(delta: float) -> void:
	directionToPointer = get_global_mouse_position() - global_position
	if(isWalking):
		velocity = input * model.walk_speed * delta * Constants.DELTA_MULTIPLIER
		var nextPostionToPointer = global_position + velocity - get_global_mouse_position()
		var walkingForward = nextPostionToPointer.length_squared() < directionToPointer.length_squared()
		animationTree["parameters/conditions/walking"] = walkingForward
		animationTree["parameters/conditions/backing"] = !walkingForward
		move_and_slide()
	else:
		animationTree["parameters/conditions/walking"] = false
		animationTree["parameters/conditions/backing"] = false
	
	try_flip_body()
	aim_weapon()
	
func try_flip_body() -> void:
	isFlipped = get_global_mouse_position().x < global_position.x
	sprite.flip_h = isFlipped
	
func aim_weapon() -> void:
	var pointerPosition = get_global_mouse_position()
	var weaponSlotPosition = weaponSlot.global_position
	var weapon_direction_to_pointer = pointerPosition - weaponSlotPosition
	var rotationToPointer : float = weapon_direction_to_pointer.angle()
	weaponSlot.set_weapon_rotation(rotationToPointer) 
	attack_zone_indicator.rotation = rotationToPointer

func take_damage() -> void:
	if(model.current_HP > 0 && invincibility_timer.is_stopped()):
		model.current_HP -= 1
		invincibility_timer.start(0.5)
		flash_red()	

func flash_red():
		sprite.modulate = Color.RED
		if(hit_tween != null):
			hit_tween.stop()
		hit_tween = get_tree().create_tween()
		hit_tween.tween_callback(sprite.set_modulate.bind(Color.WHITE)).set_delay(0.1)
		hit_tween.tween_callback(sprite.set_modulate.bind(Color.RED)).set_delay(0.1)
		hit_tween.tween_callback(sprite.set_modulate.bind(Color.WHITE)).set_delay(0.1)
		hit_tween.tween_callback(sprite.set_modulate.bind(Color.RED)).set_delay(0.1)
		hit_tween.tween_callback(sprite.set_modulate.bind(Color.WHITE)).set_delay(0.1)
		
func pickup_XP(experience : int) -> void:
	model.current_XP += experience
	
func on_throw_action():
	if(axe == null):
		axe = axe_scene.instantiate() as Axe
		get_parent().add_child(axe)
		axe.global_position = global_position
		axe.throw(directionToPointer.normalized(), self)
		EventBus.ranged_attack.emit(true)
	elif(axe.is_recalled): #ignore input if the axe is on it's way
		return
	else:
		axe.recall()
		
func on_axe_returned():
	axe.queue_free()
	axe = null
	EventBus.ranged_attack.emit(false)
