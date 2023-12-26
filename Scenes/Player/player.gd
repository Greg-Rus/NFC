class_name Player
extends CharacterBody2D

@export var speed : float = 100
@export var hit_points_max : int = 5
@export var hit_points_current : int

@onready var animationTree : AnimationTree = $AnimationTree
@onready var sprite : Sprite2D = $Sprite2D
@onready var weaponSlot : Node2D = $WeaponSlotRoot
var isFlipped : bool = false
var invincibility_timer : Timer
var hit_tween : Tween

func _ready():
	hit_points_current = hit_points_max
	EventBus.player_health_changed.emit()
	invincibility_timer = Timer.new()
	invincibility_timer.one_shot = true
	add_child(invincibility_timer)	

func _physics_process(delta: float) -> void:
	var input : Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity = input * speed * delta * Constants.DELTA_MULTIPLIER
	var isWalking : bool = input != Vector2.ZERO
	animationTree["parameters/conditions/idle"] = !isWalking

	if(isWalking):
		var directionToPointer = global_position - get_global_mouse_position()
		var nextPostionToPointer = global_position + velocity - get_global_mouse_position()
		var walkingForward = nextPostionToPointer.length_squared() < directionToPointer.length_squared()
		animationTree["parameters/conditions/walking"] = walkingForward
		animationTree["parameters/conditions/backing"] = !walkingForward
	else:
		animationTree["parameters/conditions/walking"] = false
		animationTree["parameters/conditions/backing"] = false
	
	try_flip_body()
	aim_weapon()
	move_and_slide()
	
func try_flip_body() -> void:
	isFlipped = get_global_mouse_position().x < global_position.x
	sprite.flip_h = isFlipped
	
func aim_weapon() -> void:
	var pointerPosition = get_global_mouse_position()
	var weaponSlotPosition = weaponSlot.global_position
	var directionToPointer = pointerPosition - weaponSlotPosition
	var rotationToPointer = directionToPointer.angle()
	var correctedAngle = rotationToPointer
	weaponSlot.set_weapon_rotation(correctedAngle) 

func take_damage() -> void:
	if(hit_points_current > 0 && invincibility_timer.is_stopped()):
		hit_points_current -= 1
		invincibility_timer.start(0.5)
		flash_red()	
		EventBus.player_health_changed.emit()

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
