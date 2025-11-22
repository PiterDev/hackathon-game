extends RigidBody3D

enum EnemyType {
	BUMPER,
	SHREDDER,
}

func initialize(type: EnemyType, hitter_basis: Basis) -> void:
	$KillParticle.fire()
	if type == EnemyType.BUMPER:
		$BumperModel.show()
		$ShredderModel.hide()
		var tween = create_tween()
		tween.tween_property($BumperModel, "scale", Vector3.ZERO, 1.0)
	else:
		$BumperModel.hide()
		$ShredderModel.show()
		var tween = create_tween()
		tween.tween_property($ShredderModel, "scale", Vector3.ZERO, 1.0)
		

	
	angular_velocity = Vector3(randf_range(-2,2), randf_range(-2,2), randf_range(-2,2))
	var knockback_direction: Vector3 = -hitter_basis.z 
	knockback_direction.y += 0.5 
	var knockback_speed: float = 60.0
	
	linear_velocity = knockback_direction.normalized() * knockback_speed
	linear_velocity.y = 2.0 

	await get_tree().create_timer(1.0).timeout
	queue_free()
