extends Node3D

var curr_lvl := -1

const lvls = ["res://scenes/main_game_scene_old/game.tscn"]

func _on_death_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		get_tree().change_scene_to_file("res://scenes/main_menu/menu.tscn")

func load_lvl() -> void:
	get_tree().change_scene_to_file(lvls[curr_lvl])

func _next_lvl() -> void:
	curr_lvl += 1
	load_lvl()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
