class_name Enemy
extends CharacterBody3D

## Configuration for the enemy's movement characteristics
# This speed is now set by the RhythmManager to ensure on-beat arrival
var speed: float = 0.0 
@export var rotation_speed: float = 8.0 # Speed for smooth rotation (higher = snappier)
@export var arrival_distance: float = 1.0 # Set to 1.0 meter as requested ("within 1 meter")

# The target position, set when the enemy is spawned
var target_position: Vector3 = Vector3.ZERO
var has_target: bool = false

enum EnemyType {
	BUMPER,
	SHREDDER,
}

var own_type: EnemyType

## Initializes the enemy's target position and speed.
## 'required_speed' is calculated by the RhythmManager to ensure on-beat arrival.
func initialize(pos: Vector3, required_speed: float, type: EnemyType) -> void:
	# Set the calculated speed
	speed = required_speed
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

	# Make the enemy immediately face the target when initialized
	look_at(target_position, Vector3.UP)

func _physics_process(delta: float) -> void:
	if not has_target:
		return

	# 1. Calculate the direction vector to the target (now includes the Y-axis)
	var direction_vector = target_position - global_position

	# 2. Check for arrival (within 1 meter)
	if direction_vector.length() < arrival_distance:
		# Enemy has arrived at the target position within the 1-meter range
		velocity = Vector3.ZERO
		set_physics_process(false)# Stop processing physics once target is reached
		die()
		
		return

	# 3. Calculate movement velocity
	# The direction is normalized in 3D space, giving straight-line movement.
	var move_direction = direction_vector.normalized()
	velocity = move_direction * speed

	# 4. Handle smooth rotation to face the target
	# We calculate the target rotation based on the horizontal (X and Z) direction
	var target_angle = atan2(move_direction.x, move_direction.z)

	# Lerp the current rotation (Y-axis) towards the target angle
	var current_angle = rotation.y
	rotation.y = lerp_angle(current_angle, target_angle, delta * rotation_speed)

	# 5. Move the CharacterBody3D and resolve collisions
	move_and_slide()


func die() -> void:
	$CollisionShape3D.set_deferred("disabled", true)
	hide()
	queue_free()
