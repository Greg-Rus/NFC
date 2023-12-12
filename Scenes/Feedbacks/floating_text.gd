extends Node2D

@export var normal_hit_color : Color
@export var crit_hit_color: Color
@export var glancing_hit_color: Color

@onready var label : Label = $Label
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

func init(number: String, offset: Vector2, damage_type: Constants.DAMAGE_TYPE):
	label.text = number
	label.modulate = get_text_color(damage_type)
	play_animation(damage_type)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", offset, animationPlayer.get_animation("float_text").length).as_relative().set_ease(Tween.EASE_OUT)
	
	tween.play()
	
func get_text_color(damage_type: Constants.DAMAGE_TYPE) -> Color:
	match damage_type:
		Constants.DAMAGE_TYPE.NORMAL:
			return normal_hit_color
		Constants.DAMAGE_TYPE.CRIT:
			return crit_hit_color
		Constants.DAMAGE_TYPE.GLANCE:
			return glancing_hit_color
		_:
			return normal_hit_color
			
func play_animation(damage_type: Constants.DAMAGE_TYPE) -> void:
	match damage_type:
		Constants.DAMAGE_TYPE.NORMAL:
			animationPlayer.play("float_text")
		Constants.DAMAGE_TYPE.CRIT:
			animationPlayer.play("crit")
		Constants.DAMAGE_TYPE.GLANCE:
			animationPlayer.play("glance")
		_:
			pass
