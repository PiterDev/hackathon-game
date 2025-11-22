extends Node

# --- Constants ---
const DATA_FILE_PATH := "res://maps/song1.json" # Adjust the path as necessary

# --- Onready Variables ---
@onready var enemy_spawner: Node = $"../EnemySpawner"
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# --- Member Variables ---
var current_time := 0.0
var spawn_times: Array = [] # Stores the times loaded from the JSON
var next_spawn_index := 0            # Index of the next time to check in spawn_times

const bpm_length := 120 / 60.0

# --- Setup ---
func _ready() -> void:
	# 1. Load the spawn times from the JSON file
	if not load_spawn_data():
		push_error("Failed to load or parse spawn data from %s" % DATA_FILE_PATH)
		set_process(false) # Disable _process if loading fails
		return
	
	# 2. Start the music
	audio_stream_player.play()
	
	# 3. Initialize next_spawn_index
	if spawn_times.size() > 0:
		next_spawn_index = 0
	else:
		push_warning("Spawn times list is empty.")
		
# --- Main Logic ---
func _process(delta: float) -> void:
	# Only run if there are still spawn times left
	if next_spawn_index >= spawn_times.size():
		return
		
	# Accurately calculate the current playback time
	current_time = audio_stream_player.get_playback_position()
	current_time += AudioServer.get_time_since_last_mix()
	current_time -= AudioServer.get_output_latency()

	# Check if the current time has passed the next scheduled spawn time
	if current_time >= spawn_times[next_spawn_index]:
		# Spawn the enemy
		enemy_spawner.spawn_enemy(randi_range(0,2), randi_range(0,1))
		
		# Move to the next spawn time
		next_spawn_index += 1

# --- Data Loading Function ---
func load_spawn_data() -> bool:
	var file = FileAccess.open(DATA_FILE_PATH, FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		push_error("Error opening file: %s" % DATA_FILE_PATH)
		return false
	
	var json_string = file.get_as_text()
	var json_result = JSON.parse_string(json_string)
	for i in json_result.size():
		json_result[i] = json_result[i] * bpm_length
	
	if json_result == null: # JSON.parse_string returns null on error
		push_error("Error parsing JSON string in %s" % DATA_FILE_PATH)
		return false
	
	# Ensure the parsed result is an Array of floats
	if json_result is Array:
		# Optionally, you can add a check here to ensure all elements are floats/numbers
		spawn_times = json_result
		return true
	else:
		push_error("JSON data is not an array in %s" % DATA_FILE_PATH)
		return false
