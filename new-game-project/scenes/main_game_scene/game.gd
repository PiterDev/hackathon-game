extends Node3D

var curr_lvl := -1

const lvls = ["res://scenes/main_game_scene/game.tscn"]

func _on_death_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		get_tree().change_scene_to_file("res://scenes/main_menu/menu.tscn")

func load_lvl() -> void:
	get_tree().change_scene_to_file(lvls[curr_lvl])

func _next_lvl() -> void:
	curr_lvl += 1
	load_lvl()
