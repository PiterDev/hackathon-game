class_name Enemy
extends CharacterBody3D

signal player_hit()
## Configuration for the enemy's movement characteristics
# This speed is now set by the RhythmManager to ensure on-beat arrival
var speed: float = 10.0 
@export var rotation_speed: float = 8.0 # Speed for smooth rotation (higher = snappier)
@export var arrival_distance: float = 1.0 # Set to 1.0 meter as requested ("within 1 meter")

# The target position, set when the enemy is spawned
var target_position: Vector3 = Vector3.ZERO
var has_target: bool = false
var ragdoll_scene := preload("res://enemy_ragdoll.tscn")

enum EnemyType {
	BUMPER,
	SHREDDER,
}

var own_type: EnemyType

## Initializes the enemy's target position and speed.
## 'required_speed' is calculated by the RhythmManager to ensure on-beat arrival.
func initialize(pos: Vector3, type: EnemyType) -> void:
	# Set the calculated speed
	own_type = type
	if type == EnemyType.BUMPER:
		$BumperModel.show()
		$ShredderModel.hide()
	else:
		$BumperModel.hide()
		$ShredderModel.show()
	
	# Set the target position (full 3D movement)
	target_position = pos
	has_target = true
	
	# Ensure the speed is valid
	if speed <= 0:
		print("Error: Required speed is zero or negative. Enemy will not move.")
		set_physics_process(false)
		return

func _physics_process(delta: float) -> void:
	if not has_target:
		return

	var direction_vector = target_position - global_position

	if direction_vector.length() < arrival_distance:
		velocity = Vector3.ZERO
		set_physics_process(false)# Stop processing physics once target is reached
		player_hit.emit()
		die()
		return

	var move_direction = direction_vector.normalized()
	velocity = move_direction * speed

	var target_angle = atan2(move_direction.x, move_direction.z)

	var current_angle = rotation.y
	rotation.y = lerp_angle(current_angle, target_angle, delta * rotation_speed)

	move_and_slide()


func die() -> void:
	$CollisionShape3D.set_deferred("disabled", true)
	hide()
	var ragdoll := ragdoll_scene.instantiate()
	get_parent().add_child(ragdoll)
	ragdoll.initialize(own_type)
	ragdoll.transform = transform
	queue_free()
