extends Node2D
class_name PlayerModel

@export var _max_HP : int
var max_HP : int:
	get:
		return _max_HP
	set(val):
		var max_HP_delta = val - _max_HP #if we gain max heath heal for the extra amount.
		if(max_HP_delta > 0):
			current_HP += max_HP_delta
		_max_HP = val
		EventBus.max_HP_changed.emit(_max_HP)

@export var _current_HP : int
var current_HP : int:
	get:
		return _current_HP
	set(val):
		if(val > max_HP): #we can't heatl past our max HP
			val = max_HP
		_current_HP = val
		EventBus.player_HP_changed.emit(_current_HP, _max_HP)

@export var walk_speed : float

@export var _current_XP : int
var current_XP : int:
	get:
		return _current_XP
	set(val):
		_current_XP = val
		EventBus.XP_changed.emit(_current_XP)

@export var _current_level : int
var current_level : int:
	get:
		return _current_level
	set(val):
		_current_level = val
		EventBus.level_changed.emit(_current_level)

#unused
@export var max_MP : int

@export var current_MP : int
