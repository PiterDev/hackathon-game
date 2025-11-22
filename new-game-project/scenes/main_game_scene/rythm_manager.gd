extends Node

# --- EXTERNAL NODE REFERENCES (MUST BE CONFIGURED IN SCENE) ---
@onready var enemy_spawner: Node = $"../EnemySpawner"
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player_node: Node3D = $"../Player"      # Reference to your player's Node3D
var current_time := 0.0

# --- MAP DATA AND TRAVEL CONSTANTS ---
const MAP_FILE_PATH := "res://maps/map1-easy.json" # Change path as needed
# The fixed time (in seconds) the enemy needs to travel from spawn to player.
# This dictates the visual 'lead time' and the enemy's speed.
const ENEMY_TRAVEL_TIME := 1.5 

var arrival_timestamps: Array = []
var next_note_index: int = 0
var enemy_type_to_spawn: int = 0 # Corresponds to EnemyTypes.FIRST

func _ready() -> void:
	randomize() 

	if not player_node or not enemy_spawner:
		printerr("Rhythm Manager setup error: Missing essential nodes.")
		set_process(false)
		return
		
	if not _load_map_data(MAP_FILE_PATH):
		printerr("Rhythm Manager: Failed to load map data. Stopping process.")
		set_process(false)
		return

	# Start playback immediately after loading the map
	audio_stream_player.play()

# --- MAP LOADING ---

func _load_map_data(path: String) -> bool:
	var file = FileAccess.open(path, FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		printerr("Failed to open map file: %s" % path)
		return false

	var json_text = file.get_as_text()
	var json_data = JSON.parse_string(json_text)
	
	if typeof(json_data) == TYPE_DICTIONARY and json_data.has("timestamps"):
		arrival_timestamps = json_data["timestamps"]
		print("Successfully loaded %d timestamps from map." % arrival_timestamps.size())
		return true
	else:
		printerr("JSON parsing failed or 'timestamps' key is missing.")
		return false

# --- GAME LOOP ---

func _process(_delta: float) -> void:
	if arrival_timestamps.is_empty() or next_note_index >= arrival_timestamps.size():
		return # No more notes to spawn

	# Get current accurate song time, correcting for latency
	current_time = audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix()
	current_time -= AudioServer.get_output_latency()

	# Get the target arrival time for the current note
	var arrival_time = arrival_timestamps[next_note_index]
	
	# Calculate the required spawn time
	var required_spawn_time = arrival_time - ENEMY_TRAVEL_TIME
	
	if current_time >= required_spawn_time:
		_spawn_next_enemy(arrival_time)
		
		# Move to the next note in the sequence
		next_note_index += 1
		
		if next_note_index >= arrival_timestamps.size():
			print("All notes spawned.")


func _spawn_next_enemy(_target_arrival_time: float) -> void:
	# 1. Select a single random spawn point
	var max_index = enemy_spawner.spawnpoints.size()
	var spawn_index: int = -1
	
	if max_index > 0:
		spawn_index = randi_range(0, max_index - 1)
	
	if spawn_index != -1:
		# 2. Get the spawn position and target position
		var spawn_pos = enemy_spawner.get_spawn_position(spawn_index)
		var target_pos = player_node.global_position
		
		# 3. Calculate speed (Distance / Fixed Travel Time)
		var required_speed = _calculate_required_speed(spawn_pos, ENEMY_TRAVEL_TIME)
		
		# 4. Launch the enemy
		enemy_spawner.spawn_enemy(spawn_index, required_speed, target_pos, enemy_type_to_spawn)
	else:
		printerr("Rhythm Manager: Cannot spawn, no valid spawn points available.")


## Calculates the speed required for the enemy to travel from a given spawn point
## to the player's position in exactly required_travel_time seconds.
func _calculate_required_speed(spawn_pos: Vector3, required_travel_time: float) -> float:
	# 1. Calculate the total straight-line distance (D)
	var goal_pos: Vector3 = player_node.global_position
	var total_distance: float = spawn_pos.distance_to(goal_pos)
	
	# 2. Calculate the required speed (S = D / T)
	if required_travel_time <= 0:
		return 0.0 # Prevent division by zero
		
	var required_speed: float = total_distance / required_travel_time
	
	return required_speed
