extends MultiplicativeDamageBonusBase

var consecutive_hits : int
var max_consecutive_hits = 3

func _ready():
	consecutive_hits = 0
	bonus_multiplier_percentage = 20
	EventBus.enemy_hit_melee.connect(on_enemy_hit_melee)
	EventBus.melee_attack.connect(on_melee_attack)

func apply_multiplier(damage_table):
	damage_table[Constants.DAMAGE_TABLE.TOTAL_MULTIPLIER] += consecutive_hits * bonus_multiplier_percentage
	
func on_enemy_hit_melee():
	if(consecutive_hits < max_consecutive_hits):
		consecutive_hits += 1
		
func on_melee_attack(is_attacking : bool):
	if(is_attacking == false):
		consecutive_hits = 0

