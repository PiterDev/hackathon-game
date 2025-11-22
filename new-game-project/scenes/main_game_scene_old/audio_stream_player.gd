extends AudioStreamPlayer

@onready var death_animation: AnimationPlayer = $"../DeathAnimation"

func _on_player_dead() -> void:
	death_animation.play("death")


func _on_player_mess_up() -> void:
	death_animation.play("mess_up")
