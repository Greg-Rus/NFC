extends MultiplicativeDamageBonusBase

@export var crit_chance : float = 0.1

func _ready():
	bonus_multiplier_percentage = 100

func apply_multiplier(damage_table):
	if(randf() <= crit_chance):
		damage_table[Constants.DAMAGE_TABLE.TOTAL_MULTIPLIER] += bonus_multiplier_percentage
		damage_table[Constants.DAMAGE_TABLE.IS_CRIT] = true
