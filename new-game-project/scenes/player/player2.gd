extends CharacterBody3D
# Adapted from https://kidscancode.org/godot_recipes/4.x/3d/basic_fps/index.html

@onready var timer: Timer = $Timer
@onready var rig: Node3D = $Camera3D/ArmsRig
@onready var health_bar_temp: ProgressBar = $CanvasLayer/Control/HealthBarTemp

var cooled := false

var speed := 5
var mouse_sensitivity := 0.001
var health: int = 3


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	$Crosshair.rotation += delta
	
	if $Camera3D/AttackRaycast.is_colliding(): 
		if $Camera3D/AttackRaycast.get_collider() and $Camera3D/AttackRaycast.get_collider().is_in_group("Enemy"):
			$Crosshair.modulate = Color(0.894, 0.0, 0.0, 1.0)
		else:
			$Crosshair.modulate = Color(0.894, 1.0, 1.0, 1.0)
	else:
		$Crosshair.modulate = Color(0.894, 1.0, 1.0, 1.0)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
		
	if event.is_action_pressed("Action"):
		rig.animation_player.seek(0)
		$AnimationPlayer.seek(0)
		$AnimationPlayer.play("camera_thump")
		$SwingSound.play()
		rig.play_anim("Attack")
		attack()
	elif event.is_action_pressed("Deaction"):
		rig.animation_player.seek(0)
		$AnimationPlayer.seek(0)
		$SwingSound.play()
		$AnimationPlayer.play("camera_unthump")
		rig.play_anim("DefendEndure")
		defend()
		
	if !cooled:
		if event.is_action_pressed("Action"):
			rig.animation_player.seek(0)
			$AnimationPlayer.seek(0)
			$AnimationPlayer.play("camera_thump")
			rig.play_anim("Attack")
			attack()
			cooled = true
			timer.start()
		elif event.is_action_pressed("Deaction"):
			cooled = true
			rig.animation_player.seek(0)
			rig.play_anim("DefendEndure")
			$AnimationPlayer.play("camera_unthump")
			defend()
			timer.start()
		

	
func attack() -> void:
	$Camera3D/AttackRaycast.force_raycast_update()
	var collider := $Camera3D/AttackRaycast.get_collider() as Object
	if collider and collider.is_in_group("Enemy") and collider.own_type == Enemy.EnemyType.BUMPER:
		# Calculate precision, add score
		$AttackSound.play(0.0)
		var enemy := collider as CharacterBody3D
		$Camera3D.shake(10.0)
		enemy.die(true)
		$HitSound.play()
	else:
		# Subtract from score
		pass

func defend() -> void:
	$Camera3D/AttackRaycast.force_raycast_update()
	var collider := $Camera3D/AttackRaycast.get_collider() as Object
	if collider and collider.is_in_group("Enemy") and collider.own_type == Enemy.EnemyType.SHREDDER:
		# Calculate precision, add score
		$Camera3D.shake(6.0)
		$DefendSound.play(0.0)
		var enemy := collider as CharacterBody3D
		enemy.die(true)
		$HitSound.play()
	else:
		# Subtract from score
		pass

func take_hit():
	$Control/TextureRect/AnimationPlayer.play("hurt")
	health -= 1
	health_bar_temp.value = health
	if health <= 0:
		print_debug("GGs")


func can_fight() -> void:
	cooled = false
	
