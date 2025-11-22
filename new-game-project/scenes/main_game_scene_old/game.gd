extends Node3D


func _on_death_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		get_tree().change_scene_to_file("res://scenes/main_menu/menu.tscn")

func _next_lvl() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/menu.tscn")
