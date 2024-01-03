extends Node2D
class_name FloatingText

@onready var label : Label = $Label
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

func init(number: String, offset: Vector2, is_crit : bool = false):
	label.text = number
	if(!is_crit):
		animationPlayer.play("float_text")
	else:
		animationPlayer.play("float_crit_text")
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", offset, animationPlayer.get_animation("float_text").length).as_relative().set_ease(Tween.EASE_OUT)
	
	tween.play()
