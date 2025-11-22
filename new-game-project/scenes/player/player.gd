extends CharacterBody3D
# Adapted from https://kidscancode.org/godot_recipes/4.x/3d/basic_fps/index.html

@onready var timer: Timer = $CanFightTimer
@onready var rig: Node3D = $Camera3D/ArmsRig
@onready var sway_point: Node3D = $Camera3D/Node3D
@onready var health_bar_temp: ProgressBar = $CanvasLayer/Control/HealthBarTemp
@onready var score_bar: Control = $ScoreBar

@onready var game_env : WorldEnvironment = get_tree().get_root().get_node("Game/MainScene/WorldEnvironment")

var cooled := false

var alive := true

var speed := 5
var mouse_sensitivity := 0.001
var health: int = 5

var interaction_blocked := false
var invincible := false

signal dead
signal mess_up

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _process(delta) -> void:
	rig.global_transform = lerp(rig.global_transform, sway_point.global_transform, 15*delta)

func _physics_process(delta: float) -> void:
	$Crosshair.rotation += delta
	
	if $Camera3D/AttackRaycast.is_colliding(): 
		if $Camera3D/AttackRaycast.get_collider() and $Camera3D/AttackRaycast.get_collider().is_in_group("Enemy"):
			$Crosshair.modulate = Color(0.894, 0.0, 0.0, 1.0)
		else:
			$Crosshair.modulate = Color(0.894, 1.0, 1.0, 1.0)
	else:
		$Crosshair.modulate = Color(0.894, 1.0, 1.0, 1.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
		
	if event.is_action_pressed("Action") and not interaction_blocked:
		rig.animation_player.seek(0)
		$AnimationPlayer.seek(0)
		$AnimationPlayer.play("camera_thump")
		rig.play_anim("Attack")
		$Swoosh.play()
		attack()
	elif event.is_action_pressed("Deaction") and not interaction_blocked:
		rig.animation_player.seek(0)
		$AnimationPlayer.seek(0)
		$AnimationPlayer.play("camera_unthump")
		rig.play_anim("DefendEndure")
		$Swoosh.play()
		defend()
		
	if not cooled and not interaction_blocked:
		if event.is_action_pressed("Action"):
			rig.animation_player.seek(0)
			$AnimationPlayer.seek(0)
			$AnimationPlayer.play("camera_thump")
			rig.play_anim("Attack")
			attack()
			cooled = true
			$Swoosh.play()
			timer.start()
		elif event.is_action_pressed("Deaction"):
			cooled = true
			rig.animation_player.seek(0)
			rig.play_anim("DefendEndure")
			$AnimationPlayer.play("camera_unthump")
			$Swoosh.play()
			defend()
			timer.start()
		

	
func attack() -> void:
	$Camera3D/AttackRaycast.force_raycast_update()
	var collider := $Camera3D/AttackRaycast.get_collider() as Object
	if collider and collider.is_in_group("Enemy") and collider.own_type == Enemy.EnemyType.BUMPER:
		# Calculate precision, add score
		$AttackSound.play(0.0)
		var enemy := collider as CharacterBody3D
		score_bar.add_to_score(50) # dont ask why this is 100
		$Camera3D.shake(10.0)
		enemy.die(true)
		$Hit.play()
	else:
		$AirHitCooldown.start()
		mess_up.emit()
		interaction_blocked = true

func defend() -> void:
	$Camera3D/AttackRaycast.force_raycast_update()
	var collider := $Camera3D/AttackRaycast.get_collider() as Object
	if collider and collider.is_in_group("Enemy") and collider.own_type == Enemy.EnemyType.SHREDDER:
		# Calculate precision, add score
		$DefendSound.play(0.0)
		score_bar.add_to_score(50) # dont ask why this is 100
		var enemy := collider as CharacterBody3D
		
		enemy.die(true)
		$Hit.play()
	else:
		$AirHitCooldown.start()
		mess_up.emit()
		interaction_blocked = true

func take_hit():
	if invincible:
		return
	$Control/TextureRect/AnimationPlayer.play("hurt")
	score_bar.remove_from_score(50)
	health -= 1
	
	game_env.environment.adjustment_saturation = health*0.2
	
	if health <= 0 and alive:
		$AnimationPlayer.play("death")
		dead.emit()
		alive = false
	else:
		invincible = true
		$InvincibilityTimer.start()


func can_fight() -> void:
	cooled = false


func _on_air_hit_cooldown_timeout() -> void:
	interaction_blocked = false


func _on_invincibility_timer_timeout() -> void:
	invincible = false
