extends RigidBody2D

enum ENEMY_STATE {IDLE, MOVING, ATTACKING, GETTING_HIT, DYING, DEAD} 

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@export var moveForce : float
@export var detection_range : float = 100
@export var attack_range : float = 30
@export var hit_points : float = 5
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
		draw_line(Vector2.ZERO, directionToPlayer.normalized() * moveForce, Color.RED, 1)

func _ready():
	animationPlayer.play("enemy_idle")

func _process(delta):
	updateDirectionToPlayer()
	process_current_state(delta)
	try_flip_body()
	if(draw_debug):
		queue_redraw()
	
func _physics_process(delta):
	if(current_state == ENEMY_STATE.MOVING):
		apply_central_impulse (directionToPlayer.normalized() * moveForce)
	
func process_current_state(delta: float):
	match current_state:
		ENEMY_STATE.IDLE:
			process_idle()
		ENEMY_STATE.MOVING:
			move_to_player(delta)
		ENEMY_STATE.ATTACKING:
			process_attacking()
		ENEMY_STATE.GETTING_HIT:
			process_getting_hit(delta)
			
func transitionToState(state: ENEMY_STATE):
	current_state = state
	animationPlayer.stop()
	match state:
		ENEMY_STATE.IDLE:
			animationPlayer.play("enemy_idle")
		ENEMY_STATE.MOVING:
			animationPlayer.play("enemy_move")
		ENEMY_STATE.ATTACKING:	
			pass
		ENEMY_STATE.GETTING_HIT:
			animationPlayer.play("enemy_damage")
	
func process_idle():
	if(directionToPlayer.length() <= detection_range):
		transitionToState(ENEMY_STATE.MOVING)
	
func move_to_player(delta: float):
	if(directionToPlayer.length() <= attack_range):
		transitionToState(ENEMY_STATE.ATTACKING)
		
func process_attacking():
	if(!animationPlayer.is_playing()):
			animationPlayer.play("enemy_attack")
	if(directionToPlayer.length() > attack_range):
		transitionToState(ENEMY_STATE.MOVING)
		
func process_getting_hit(delta: float):
	hit_stun_timer += delta
	if(hit_stun_timer >= hit_stun_time):
		transitionToState(ENEMY_STATE.MOVING)
		hit_stun_timer = 0
	
func updateDirectionToPlayer() :
	directionToPlayer = player.position - position
	
func try_flip_body():
	isFlipped = directionToPlayer.x < 0
	sprite.flip_h = isFlipped

func take_damage(damage: int):
	hit_points -= damage
	transitionToState(ENEMY_STATE.GETTING_HIT)
	
