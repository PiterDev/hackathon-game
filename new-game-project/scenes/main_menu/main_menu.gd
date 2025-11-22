extends Control

const PLAY_BUTTON_SCENE_PATH: String = "res://scenes/cut_scene/cut_scene.tscn"
@onready var menu_idle: AnimationPlayer = $SubViewportContainer/SubViewport/Node3D/MenuIdle


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	menu_idle.play("idle")

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_play_button_pressed() -> void:
	assert(PLAY_BUTTON_SCENE_PATH.length() != 0, "No play button scene path specified")
	get_tree().change_scene_to_file(PLAY_BUTTON_SCENE_PATH)
	
