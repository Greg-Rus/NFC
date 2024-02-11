class_name Player
extends CharacterBody2D

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var weaponSlot : WeaponSlot = $WeaponSlotRoot
@onready var axe_scene = preload("res://Scenes/Weapons/axe.tscn")
@onready var camera_remote : RemoteTransform2D = %CameraRemote
@onready var attack_zone_indicator : AttackZoneIndicator = $AttackZoneIndicator
@onready var hp_bar : TextureProgressBar = $HealthProgressBar
@onready var rage_bar : TextureProgressBar = $RageProgressBar
@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var dash_vfx : DashTrail = $Vfx/DashTrail

var model : PlayerModel

var isFlipped : bool = false
var invincibility_timer : Timer
var hit_tween : Tween
var isWalking : bool
var walk_input : Vector2
var look_direction : Vector2
var axe : Axe
var read_mouse : bool = true
var read_controller: bool = false
var last_mouse_input : Vector2
var viewport : Viewport
var is_dashing : bool = false
var dash_origin : Vector2
var dash_direction : Vector2

func _ready():
	model = %Model
	invincibility_timer = Timer.new()
	invincibility_timer.one_shot = true
	add_child(invincibility_timer)	
	viewport = GameManager.main_camera.get_viewport()
	camera_remote.remote_path = GameManager.main_camera.get_path()
	attack_zone_indicator.init(weaponSlot.position, weaponSlot.weapon.model.range, weaponSlot.weapon.model.weapon_arc_degrees)
	animationPlayer.play("iris_idle")
	EventBus.player_HP_changed.connect(on_hp_change)
	EventBus.rage_changed.connect(on_rage_change)
	on_hp_change(model.current_HP, model.max_HP)
	on_rage_change(model.current_rage, model.max_rage)
	
func on_hp_change(current : float, max : float):
	hp_bar.value = current / max
	
func on_rage_change(current : float, max : float):
	rage_bar.value = current / max
	
func _process(_delta):
	read_input()
	isWalking = walk_input != Vector2.ZERO
	if(!isWalking && !weaponSlot.is_spinning):
		animationPlayer.play("iris_idle")
	if(Input.is_action_just_pressed("Throw")):
		on_throw_action()
	if(Input.is_action_just_pressed("Dash")):
		if(model.can_dahs()):
			start_dash()
		
func on_spin_start():
	animationPlayer.play("iris_spin")

func _physics_process(delta: float) -> void:
	if(isWalking && !is_dashing):
		velocity = walk_input * model.walk_speed * delta * Constants.DELTA_MULTIPLIER
		var walkingForward = (velocity.x > 0 && look_direction.x > 0) || (velocity.x < 0 && look_direction.x < 0)
		move_and_slide()
				
		if(!weaponSlot.is_spinning):
			if(walkingForward):
				animationPlayer.play("iris_run")
			else:
				animationPlayer.play("iris_run", -1, -1.0)
				
	if(isWalking && is_dashing):
		velocity = walk_input * model.dash_speed * delta * Constants.DELTA_MULTIPLIER
		move_and_slide()
		var dash_progress = dash_origin.distance_to(global_position) / model.dash_distance
		if(dash_progress >= 1):
			end_dash()
		else:
			dash_vfx.update(dash_progress)
		
	try_flip_body()
	aim_weapon()
	
func read_input():
	if(!is_dashing):
		walk_input = Input.get_vector("left", "right", "up", "down")
	
	if(read_mouse):
		look_direction = get_global_mouse_position() - global_position
		if(Input.get_vector("look_left", "look_right", "look_up", "look_down") != Vector2.ZERO):
			read_mouse = false
			read_controller = true
	
	if(read_controller):
		var controller_look = Input.get_vector("look_left", "look_right", "look_up", "look_down")
		if(controller_look != Vector2.ZERO):
			look_direction = controller_look
		if(last_mouse_input != viewport.get_mouse_position()):
			read_mouse = true
			read_controller = false
	last_mouse_input = viewport.get_mouse_position()
	
func try_flip_body() -> void:
	isFlipped = weaponSlot.rotation_degrees > 90 || weaponSlot.rotation_degrees < -90
	sprite.flip_h = isFlipped
	
func aim_weapon() -> void:
	var rotationToPointer : float = look_direction.angle()
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
		axe.throw(look_direction.normalized(), self)
		EventBus.ranged_attack.emit(true)
	elif(axe.is_recalled): #ignore walk_input if the axe is on it's way
		return
	elif(can_recall_axe()):
		EventBus.rage_drain.emit(axe.model.recall_rage_cost)
		axe.recall()
		
func on_axe_returned():
	axe.queue_free()
	axe = null
	EventBus.ranged_attack.emit(false)
	
func can_recall_axe() -> bool:
	return axe != null && model.current_rage >= axe.model.recall_rage_cost && !axe.is_recalled
	
func start_dash() -> void:
	model.deduct_rage_for_dash()
	is_dashing = true
	dash_origin = global_position
	collision_shape.disabled = true
	dash_vfx.start()

func end_dash() -> void:
	is_dashing = false
	collision_shape.disabled = false
