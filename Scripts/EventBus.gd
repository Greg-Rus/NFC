extends Node

signal damage_taken(damage: int, global_position: Vector2)
signal player_HP_changed(current_HP : int, max_HP : int)
signal XP_changed(current_XP : int)
signal level_changed(current_level : int)
signal enemy_hit
signal attack_action(is_attacking : bool)
