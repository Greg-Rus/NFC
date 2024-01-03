extends MultiplicativeDamageBonusBase

var throw_in_progress : bool = false
var melee_attack_in_progerss : bool = false
var enemies_hit : int = 0
var cachedBonus : int = 0
var active_bonus : int = 0

func _ready():
	EventBus.ranged_attack.connect(on_ranged_attack)
	EventBus.enemy_hit_ranged.connect(on_ranged_hit)
	EventBus.melee_attack.connect(on_melee_attack)

func on_ranged_attack(is_attacking : bool):
	throw_in_progress = is_attacking
	if(!is_attacking):
		if(melee_attack_in_progerss):
			cachedBonus = bonus_multiplier_percentage * enemies_hit
		else:
			active_bonus = bonus_multiplier_percentage * enemies_hit
		enemies_hit = 0
	
func on_melee_attack(is_attacking : bool):
	melee_attack_in_progerss = is_attacking
	if(!is_attacking && cachedBonus > 0):
		active_bonus = cachedBonus
		cachedBonus = 0
	elif(!is_attacking && active_bonus > 0):
		active_bonus = 0
	
func on_ranged_hit():
	enemies_hit += 1
	
func apply_multiplier(damage_table):
	damage_table[Constants.DAMAGE_TABLE.TOTAL_MULTIPLIER] += bonus_multiplier_percentage * active_bonus
