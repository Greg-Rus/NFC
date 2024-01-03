extends Node

signal damage_taken(damage_table, global_position: Vector2)
signal player_HP_changed(current_HP : int, max_HP : int)
signal XP_changed(current_XP : int)
signal level_changed(current_level : int)
signal enemy_hit_melee()
signal enemy_hit_ranged()
signal melee_attack(is_attacking : bool)
signal ranged_attack(is_attacking : bool)
