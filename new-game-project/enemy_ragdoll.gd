extends RigidBody3D

enum EnemyType {
	BUMPER,
	SHREDDER,
}

func initialize(type: EnemyType) -> void:
	if type == EnemyType.BUMPER:
		$BumperModel.show()
		$ShredderModel.hide()
	else:
		$BumperModel.hide()
		$ShredderModel.show()
	
	angular_velocity = Vector3(randf_range(-2,2), randf_range(-2,2), randf_range(-2,2))
	linear_velocity = Vector3(randf(), -5.0, randf())
	
	await get_tree().create_timer(1.0).timeout
	queue_free()
