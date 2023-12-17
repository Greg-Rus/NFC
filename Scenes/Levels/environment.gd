class_name Environemnt
extends Node2D 

@export var player_spawn_point : Node2D
var player :Player

func add_player(player: Player) -> void:
	player.global_position = player_spawn_point.global_position
	self.player = player
	add_child(player)
	
func add_enemy(enemy: Enemy) -> void:
	add_child(enemy)
