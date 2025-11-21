extends Control

@onready var images = [
	$Control, $Control2, $Control3, $Control4
]

var index := 0

func _ready() -> void:
	for img in images:
		img.visible = true
	show_img()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Action"):
		index += 1
		if index < images.size():
			show_img()
		else:
			end_cutscene()

func show_img():
	var anim_player = images[index].get_node("AnimationPlayer")
	anim_player.play("Show")
	


func end_cutscene():
	get_tree().change_scene_to_file("res://scenes/main_game_scene/game.tscn")
