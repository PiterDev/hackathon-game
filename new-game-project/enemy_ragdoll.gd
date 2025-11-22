extends RigidBody3D

enum EnemyType {
	BUMPER,
	SHREDDER,
}

func initialize(type: EnemyType, hitter_basis: Basis) -> void:
	if type == EnemyType.BUMPER:
		$BumperModel.show()
		$ShredderModel.hide()
	else:
		$BumperModel.hide()
		$ShredderModel.show()
	
	angular_velocity = Vector3(randf_range(-2,2), randf_range(-2,2), randf_range(-2,2))
	var knockback_direction: Vector3 = -hitter_basis.z 
	knockback_direction.y += 0.5 
	var knockback_speed: float = 10.0
	
	linear_velocity = knockback_direction.normalized() * knockback_speed
	linear_velocity.y = -5.0 

	await get_tree().create_timer(1.0).timeout
	queue_free()
