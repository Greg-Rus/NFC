class_name Enemy
extends CharacterBody2D

enum ENEMY_STATE {IDLE, MOVING, ATTACKING, GETTING_HIT, DYING, DEAD} 

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var collisionShape : CollisionShape2D = $CollisionShape2D
@export var deadColor : Color
@export var moveSpeed : float
@export var acceleration: float
@export var detection_range : float = 100
@export var attack_range : float = 30
@export var hit_points : float = 5
@export var experience_drop : int = 1
@export var hit_stun_time : float = 0.6
@export var player : Node2D
@export var draw_debug :bool
@export var current_state : ENEMY_STATE = ENEMY_STATE.IDLE

var directionToPlayer: Vector2
var isFlipped: bool
var hit_stun_timer : float

func _draw() -> void:
	if(draw_debug):
		draw_circle(Vector2.ZERO, detection_range, Color.BLUE * Color(1,1,1,0.3))
		draw_circle(Vector2.ZERO, attack_range, Color.RED * Color(1,1,1,0.4))
		draw_line(Vector2.ZERO, directionToPlayer.normalized() * moveSpeed, Color.RED, 1)

func _ready() -> void:
	animationPlayer.play("enemy_idle")

func _process(delta: float) -> void:
	updateDirectionToPlayer()
	process_current_state(delta)
	try_flip_body()
	if(draw_debug):
		queue_redraw()
	
func _physics_process(delta: float) -> void:
	if(current_state == ENEMY_STATE.MOVING):
		velocity = velocity.lerp(directionToPlayer.normalized() * moveSpeed, delta * acceleration)
		move_and_slide()
		
	if(current_state == ENEMY_STATE.GETTING_HIT):
		velocity = velocity.lerp(Vector2.ZERO, delta * acceleration)
		var collision = move_and_collide(velocity * delta)
		if collision:
			velocity = velocity.bounce(collision.get_normal()) * 0.5
		
func init(player_node: Player) -> void:
	if(not player):
		player = player_node
	
func process_current_state(delta: float) -> void:
	match current_state:
		ENEMY_STATE.IDLE:
			process_idle()
		ENEMY_STATE.MOVING:
			move_to_player(delta)
		ENEMY_STATE.ATTACKING:
			process_attacking()
		ENEMY_STATE.GETTING_HIT:
			process_getting_hit(delta)
		ENEMY_STATE.DYING:
			process_dying()
			
func transitionToState(state: ENEMY_STATE) -> void:
	current_state = state
	animationPlayer.stop()
	match state:
		ENEMY_STATE.IDLE:
			animationPlayer.play("enemy_idle")
		ENEMY_STATE.MOVING:
			animationPlayer.play("enemy_move")
		ENEMY_STATE.ATTACKING:	
			animationPlayer.play("enemy_attack")
		ENEMY_STATE.GETTING_HIT:
			animationPlayer.play("enemy_damage")
		ENEMY_STATE.DYING:
			animationPlayer.play("enemy_die")
			collisionShape.set_deferred("disabled", true)
			sprite.modulate = deadColor
			z_index = Constants.DEAD_Z_INDEX
		ENEMY_STATE.DEAD:
			GameManager.report_enemy_death(experience_drop, global_position)
			queue_free()
	
func process_idle() -> void:
	if(directionToPlayer.length() <= detection_range):
		transitionToState(ENEMY_STATE.MOVING)
	
func move_to_player(delta: float) -> void:
	if(directionToPlayer.length() <= attack_range):
		transitionToState(ENEMY_STATE.ATTACKING)
		
func process_attacking() -> void:
	if(!animationPlayer.is_playing()):
		if(directionToPlayer.length() > attack_range):
			transitionToState(ENEMY_STATE.MOVING)
		else:
			animationPlayer.play("enemy_attack")
		
func process_getting_hit(delta: float) -> void:
	hit_stun_timer += delta
	if(hit_stun_timer >= hit_stun_time):
		transitionToState(ENEMY_STATE.MOVING)
		hit_stun_timer = 0
		
func process_dying() -> void:
	if(!animationPlayer.is_playing()):
		transitionToState(ENEMY_STATE.DEAD)
	
func updateDirectionToPlayer() -> void:
	directionToPlayer = player.position - position
	
func try_flip_body() -> void:
	isFlipped = directionToPlayer.x < 0
	sprite.flip_h = isFlipped

func take_damage(damage: int, damage_direction: Vector2) -> void:
	hit_points = max(0, hit_points - damage)
	velocity = damage_direction
	if(hit_points > 0):
		transitionToState(ENEMY_STATE.GETTING_HIT)
	else:
		transitionToState(ENEMY_STATE.DYING)
	EventBus.damage_taken.emit(damage, global_position)
	
func deal_damage():
	if(directionToPlayer.length() < attack_range):
		player.take_damage()
