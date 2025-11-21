extends Node3D

@onready var animation_player: AnimationPlayer = $arms/AnimationPlayer

func play_anim(anim_name : String) -> void:
	animation_player.seek(0)
	animation_player.play(anim_name)
