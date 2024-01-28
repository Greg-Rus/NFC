extends Node2D
class_name Weapon

@onready var model : MaleeWeaponModel = $SwordModel
@export var particles: Array[CPUParticles2D] = []
@export var longest_particle_duration : float = 0.1
@export var particle_transparency : float = 0.06
@export var particle_amount : int = 300
var isAttacking : bool

func _ready():
	EventBus.melee_attack.connect(on_melee_attack)	
	EventBus.melee_attack_progress.connect(attack_progress)
	EventBus.spin_attack_change.connect(on_spin_attack_change)	
	EventBus.spin_attack_progress.connect(attack_progress)
	for i in particles.size():
		particles[i].amount = particle_amount
	on_melee_attack(false)
		
func deal_damage_to_enemy(enemy : Enemy):
	var direation_to_enemy : Vector2 = enemy.position - global_position
	var hit_force_vector = direation_to_enemy.normalized() * model.hit_force
	var damage_table = model.get_updated_damage_table()
	enemy.take_damage(damage_table, hit_force_vector)
	return damage_table

func on_melee_attack(is_attacking):
	isAttacking = is_attacking
	for particle in particles:
		particle.emitting = isAttacking
		
func on_spin_attack_change(is_spinning : bool):
	var duration = longest_particle_duration / particles.size()
	for i in particles.size():
		particles[i].lifetime = duration * i
		particles[i].emitting = is_spinning
		
func attack_progress(progress : float):
	var color = Color(1,1,1, particle_transparency * progress)
	for particle in particles:
		particle.color = color
