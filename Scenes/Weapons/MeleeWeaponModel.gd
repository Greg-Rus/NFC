extends Node
class_name MaleeWeaponModel

var bonusses = []

@export var hit_force : float = 50
@export var base_damage : int = 10
var damage_table = {
	Constants.DAMAGE_TABLE.DAMAGE : 0,
	Constants.DAMAGE_TABLE.TOTAL_MULTIPLIER : 100,
	Constants.DAMAGE_TABLE.IS_CRIT : false
}

func _ready():
	bonusses = get_children().filter(func (x) : return x is MultiplicativeDamageBonusBase)
	
func get_updated_damage_table():
	reset_damage_table()
	for b in bonusses:
		var bonus = b as MultiplicativeDamageBonusBase 
		bonus.apply_multiplier(damage_table)
	
	damage_table[Constants.DAMAGE_TABLE.DAMAGE] = ceil(base_damage * damage_table[Constants.DAMAGE_TABLE.TOTAL_MULTIPLIER] / 100.0)
	return damage_table

func reset_damage_table():
	damage_table[Constants.DAMAGE_TABLE.DAMAGE] = 0
	damage_table[Constants.DAMAGE_TABLE.TOTAL_MULTIPLIER] = 100
	damage_table[Constants.DAMAGE_TABLE.IS_CRIT] = false
