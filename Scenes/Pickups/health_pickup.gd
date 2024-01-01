extends BasePickup
class_name HP_Pickup

var hp_heal_amount : int = 1

func picked_up():
	player.model.current_HP += hp_heal_amount
	queue_free()
