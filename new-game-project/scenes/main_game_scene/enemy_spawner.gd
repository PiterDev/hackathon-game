extends Node

var enemy_scene := preload("res://scenes/enemy/enemy.tscn")
@onready var spawnpoints: Array[Marker3D] = [$"../Markers/Spawn1", $"../Markers/Spawn2", $"../Markers/Spawn3"]
@onready var player: CharacterBody3D = $"../Player"


func get_spawn_position(index: int) -> Vector3:
	if spawnpoints.is_empty():
		printerr("Error: Spawn points array is empty!")
		return Vector3.ZERO
	if index < 0 or index >= spawnpoints.size():
		printerr("Error: Invalid spawn index %d" % index)
		return Vector3.ZERO
		
	return spawnpoints[index].global_position

func spawn_enemy(spawn_index: int, required_speed: float, target_pos: Vector3, enemy_type: Enemy.EnemyType) -> void:
	if spawnpoints.is_empty():
		printerr("Cannot spawn enemy: Spawn points array is empty.")
		return
	if spawn_index < 0 or spawn_index >= spawnpoints.size():
		printerr("Cannot spawn enemy: Invalid spawn index %d" % spawn_index)
		return
		
	var spawn_marker = spawnpoints[spawn_index]
	
	var new_enemy := enemy_scene.instantiate() as CharacterBody3D
	
	
	get_parent().add_child(new_enemy)
	new_enemy.global_position = spawn_marker.global_position
	
	new_enemy.initialize(target_pos, required_speed, enemy_type)
	
