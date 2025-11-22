extends Control

@onready var label_score: Label = $score
@onready var animation_player: AnimationPlayer = $score/streakPanel/AnimationPlayer
@onready var label_streak: Label = $score/streakPanel/streak

var score := 0

func add_to_score(num: int) -> void:
	score += num
	label_score.text = str(score)

func remove_from_score(num: int) -> void:
	score -= num
	if score < 0:
		score = 0
	label_score.text = str(score)
