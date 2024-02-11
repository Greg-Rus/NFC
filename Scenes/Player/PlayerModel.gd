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
		EventBus.player_HP_changed.emit(current_HP, _max_HP)

@export var _current_HP : int
var current_HP : int:
	get:
		return _current_HP
	set(val):
		if(val > max_HP): #we can't heatl past our max HP
			val = max_HP
		_current_HP = val
		EventBus.player_HP_changed.emit(_current_HP, max_HP)

@export var walk_speed : float

@export var _current_XP : int
var current_XP : int:
	get:
		return _current_XP
	set(val):
		if(val >= xp_to_level_up):
			current_level += 1
			_current_XP = 0
		else :
			_current_XP = val
		EventBus.XP_changed.emit(_current_XP, xp_to_level_up)

@export var _current_level : int
var current_level : int:
	get:
		return _current_level
	set(val):
		_current_level = val
		EventBus.level_changed.emit(_current_level)
		
@export var _xp_to_level_up : int
var xp_to_level_up : int:
	get:
		return _xp_to_level_up * _current_level
	set(val):
		_xp_to_level_up = val
	
@export var _current_stamina : float
var current_stamina : float:
	get:
		return _current_stamina
	set(val):
		if(val < 0):
			_current_stamina = 0
		else:
			_current_stamina = val
		EventBus.stamina_changed.emit(_current_stamina, _max_stamina)
		
@export var _stamina_regen_per_second: float

@export var _max_stamina : float
var max_stamina : float:
	get:
		return _max_stamina
	set(val):
		_max_stamina = val

@export var _current_rage : float
var current_rage : float:
	get:
		return _current_rage
	set(val):
		if(val < 0):
			_current_rage = 0
		elif(val > max_rage):
			_current_rage = max_rage
		else:
			_current_rage = val
		EventBus.rage_changed.emit(_current_rage, _max_rage)

@export var _max_rage : float
var max_rage : float:
	get:
		return _max_rage
	set(val):
		_max_rage = val
		
@export var dash_distance : float
@export var dash_speed : float
@export var dash_cost : float
		
func _ready():
	#EventBus.stamina_drain.connect(func(drain:float): current_stamina -= drain)
	EventBus.rage_gain.connect(func(gain : float): current_rage += gain)
	EventBus.rage_drain.connect(func(drain : float): current_rage -= drain)
	current_HP = max_HP
	current_stamina = max_stamina
	current_rage = 0
	current_rage = max_rage

func _process(delta):
	if(current_stamina < max_stamina):
		current_stamina += _stamina_regen_per_second * delta
		
func can_dahs() -> bool:
	return current_rage >= dash_cost
	
func deduct_rage_for_dash() -> void:
	current_rage -= dash_cost
		
