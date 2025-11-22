extends Node

var enemy_scene := preload("res://scenes/enemy/enemy.tscn")

@onready var spawnpoints: Array[Marker3D] = [$"../Markers/Spawn1", $"../Markers/Spawn2", $"../Markers/Spawn3"]
@onready var player: CharacterBody3D = $"../Player"

func spawn_enemy(spawn_index: int, enemy_type: Enemy.EnemyType) -> void:
	var spawn_marker = spawnpoints[spawn_index]
	var new_enemy := enemy_scene.instantiate() as CharacterBody3D
	
	get_parent().add_child(new_enemy)
	new_enemy.position = spawn_marker.position
	new_enemy.initialize(player.global_position, enemy_type)
	new_enemy.player_hit.connect(player.take_hit)
