extends CharacterBody3D
# Adapted from https://kidscancode.org/godot_recipes/4.x/3d/basic_fps/index.html


@onready var rig: Node3D = $Camera3D/ArmsRig

var defending := false

var speed := 5
var mouse_sensitivity := 0.001

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
		
	if event.is_action_pressed("Action"):
		rig.animation_player.seek(0)
		$AnimationPlayer.seek(0)
		$AnimationPlayer.play("camera_thump")
		rig.play_anim("Attack")
		attack()
	elif event.is_action_pressed("Deaction"):
		rig.animation_player.seek(0)
		$AnimationPlayer.seek(0)
		$AnimationPlayer.play("camera_unthump")
		rig.play_anim("DefendEndure")
		defend()
		
	if Input.is_action_just_pressed("escape"):
		pass
	
func attack() -> void:
	$Camera3D/AttackRaycast.force_raycast_update()
	var collider := $Camera3D/AttackRaycast.get_collider() as Object
	if collider and collider.is_in_group("Enemy") and collider.own_type == Enemy.EnemyType.BUMPER:
		# Calculate precision, add score
		$AttackSound.play(0.0)
		var enemy := collider as CharacterBody3D
		enemy.die()
	else:
		# Subtract from score
		pass

func defend() -> void:
	$Camera3D/AttackRaycast.force_raycast_update()
	var collider := $Camera3D/AttackRaycast.get_collider() as Object
	if collider and collider.is_in_group("Enemy") and collider.own_type == Enemy.EnemyType.SHREDDER:
		# Calculate precision, add score
		var enemy := collider as CharacterBody3D
		enemy.die()
	else:
		# Subtract from score
		pass

func take_hit():
	$Control/TextureRect/AnimationPlayer.play("hurt")
	print("took hit")
	#animation
