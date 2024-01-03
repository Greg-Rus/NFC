extends MultiplicativeDamageBonusBase

var consecutive_hits : int
var max_consecutive_hits = 3

func _ready():
	consecutive_hits = 0
	bonus_multiplier_percentage = 20
	EventBus.enemy_hit.connect(on_enemy_hit)
	EventBus.attack_action.connect(on_attack_action)

func apply_multiplier(damage_table):
	damage_table[Constants.DAMAGE_TABLE.TOTAL_MULTIPLIER] += consecutive_hits * bonus_multiplier_percentage
	
func on_enemy_hit():
	if(consecutive_hits < max_consecutive_hits):
		consecutive_hits += 1
		
func on_attack_action(is_attacking : bool):
	if(is_attacking == false):
		consecutive_hits = 0

