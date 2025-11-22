extends TextureRect

@onready var label_score: Label = $score
@onready var animation_player: AnimationPlayer = $score/streakPanel/AnimationPlayer
@onready var label_streak: Label = $score/streakPanel/streak
var streak = 0
var score = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_streak.text = "+"+str(streak)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_score():
	if not streak>0 and score>0:
		score-=10
	else:
		score+=streak
	label_score.text = "SCORE: "+str(score)
	streak=-5
	update_streak()
	
func update_streak():
	streak+=5
	label_streak.text = "+"+str(streak)
	animation_player.play("streak_plus")
