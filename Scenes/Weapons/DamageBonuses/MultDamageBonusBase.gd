extends Node
class_name MultiplicativeDamageBonusBase

@export var bonus_multiplier_percentage : int
var model : WeaponModel

func apply_multiplier(_damage_table):
	pass

func init(current_model : WeaponModel):
	model = current_model 
