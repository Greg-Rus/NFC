extends Node2D

@onready var label : Label = $Label
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

func init(number: String, offset: Vector2):
	label.text = number
	animationPlayer.play("float_text")
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", offset, animationPlayer.get_animation("float_text").length).as_relative().set_ease(Tween.EASE_OUT)
	
	tween.play()
