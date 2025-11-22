extends AudioStreamPlayer

@onready var death_animation: AnimationPlayer = $"../DeathAnimation"

func _on_player_dead() -> void:
	death_animation.play("death")
