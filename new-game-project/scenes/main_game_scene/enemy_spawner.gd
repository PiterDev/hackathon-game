extends Node

enum EnemyTypes {
	FIRST
}
var enemy_scene := preload("res://scenes/enemy/enemy.tscn")
@onready var spawnpoints: Array[Marker3D] = [$"../Markers/Spawn1", $"../Markers/Spawn2", $"../Markers/Spawn3"]
@onready var player: CharacterBody3D = $"../Player"


## Returns the global position of the spawn point at the given index.
## The RhythmManager uses this position to calculate the required speed for that specific spawn path.
func get_spawn_position(index: int) -> Vector3:
	if spawnpoints.is_empty():
		printerr("Error: Spawn points array is empty!")
		return Vector3.ZERO
	if index < 0 or index >= spawnpoints.size():
		printerr("Error: Invalid spawn index %d" % index)
		return Vector3.ZERO
		
	return spawnpoints[index].global_position

## Spawns an enemy at the position given by 'spawn_index' and initializes it 
## with the required speed to hit 'target_pos' on the beat.
func spawn_enemy(spawn_index: int, required_speed: float, target_pos: Vector3, enemy_type: EnemyTypes) -> void:
	if spawnpoints.is_empty():
		printerr("Cannot spawn enemy: Spawn points array is empty.")
		return
	if spawn_index < 0 or spawn_index >= spawnpoints.size():
		printerr("Cannot spawn enemy: Invalid spawn index %d" % spawn_index)
		return
		
	# 1. Select the spawn marker based on the index provided by the RhythmManager
	var spawn_marker = spawnpoints[spawn_index]
	
	# 2. Instantiate and set the starting position
	var new_enemy := enemy_scene.instantiate() as CharacterBody3D
	# Use global_position for 3D world placement
	new_enemy.global_position = spawn_marker.global_position
	
	# 3. Initialize the enemy with the calculated speed and target position
	new_enemy.initialize(target_pos, required_speed)
	
	get_parent().add_child(new_enemy)
