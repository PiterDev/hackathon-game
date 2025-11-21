extends ColorRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func show_img() -> void:
	animation_player.play("Show")
