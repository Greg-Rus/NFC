extends Node

@onready var enemy_scene = preload("res://Scenes/Enemies/enemy.tscn")
#@onready var environment_scene = preload("res://Scenes/Levels/test_environment.tscn")
@onready var environment_scene = preload("res://Scenes/Levels/test_open_survival_map.tscn")
@onready var player_scene = preload("res://Scenes/Player/player_iris.tscn")
@onready var screensize : Vector2 = get_viewport().get_visible_rect().size
@export var enemy_count : int

var enemy_spawn_timer: Timer
var current_environment : Environemnt
var player : Player
var main_node : Node2D
	
func init(main : Node2D) -> void:
	main_node = main
	enemy_spawn_timer = Timer.new()
	add_child(enemy_spawn_timer)	
	
func load_environemnt() -> void:
	current_environment = environment_scene.instantiate() as Environemnt
	main_node.add_child(current_environment)
	player = player_scene.instantiate() as Player
	current_environment.add_player(player)
	enemy_spawn_timer.timeout.connect(on_enemy_spawn_timer)
	#for i in 30:
		#on_enemy_spawn_timer()
	enemy_spawn_timer.start(1)
	
func on_enemy_spawn_timer() -> void:
	spawn_enemy()
	enemy_spawn_timer.start(1)

func spawn_enemy() -> void:
	if(enemy_count >= 100):
		return
	var new_enemy = enemy_scene.instantiate() as Enemy
	new_enemy.init(player)
	current_environment.add_enemy(new_enemy)
	enemy_count += 1
