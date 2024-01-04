extends MultiplicativeDamageBonusBase
class_name LowStaminaDebuf

func apply_multiplier(damage_table):
	if(GameManager.player.model.current_stamina <= 15):
		damage_table[Constants.DAMAGE_TABLE.TOTAL_MULTIPLIER] += bonus_multiplier_percentage
