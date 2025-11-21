extends Control

const PLAY_BUTTON_SCENE_PATH: String = "res://scenes/main_game_scene/game.tscn"


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_play_button_pressed() -> void:
	assert(PLAY_BUTTON_SCENE_PATH.length() != 0, "No play button scene path specified")
	get_tree().change_scene_to_file(PLAY_BUTTON_SCENE_PATH)
	
