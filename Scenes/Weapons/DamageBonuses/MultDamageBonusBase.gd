extends Node
class_name MultiplicativeDamageBonusBase

@export var bonus_multiplier_percentage : int
var model : MaleeWeaponModel

func apply_multiplier(_damage_table):
	pass

func init(current_model : MaleeWeaponModel):
	model = current_model 
