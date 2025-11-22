extends Node

# --- Constants ---
const DATA_FILE_PATH := "res://maps/song1_v2.json" # Adjust the path as necessary

# --- Onready Variables ---
@onready var enemy_spawner: Node = $"../EnemySpawner"
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# --- Member Variables ---
var current_time := 0.0
var spawn_indexes: Array = []
var spawn_times: Array = [] # Stores the times loaded from the JSON
var next_spawn_index := 0            # Index of the next time to check in spawn_times

const bpm_length := 120 / 60.0
const ENEMY_SPEED := 15.0

@onready var player: CharacterBody3D = $"../Player"
@onready var spawn_1: Marker3D = $"../Markers/Spawn1"
@onready var spawn_2: Marker3D = $"../Markers/Spawn2"
@onready var spawn_3: Marker3D = $"../Markers/Spawn3"

@onready var distances := [
	player.global_position.distance_to(spawn_1.global_position) - 10.0,
	player.global_position.distance_to(spawn_2.global_position) - 10.0,
	player.global_position.distance_to(spawn_3.global_position) - 10.0,
]

const spawn_cooldown := 0.3
var last_spawn_time := 0.0

func _ready() -> void:
	if not load_spawn_data():
		push_error("Failed to load or parse spawn data from %s" % DATA_FILE_PATH)
		set_process(false) # Disable _process if loading fails
		return
	
	if spawn_times.size() > 0:
		next_spawn_index = 0
	else:
		push_warning("Spawn times list is empty.")
		
func _process(_delta: float) -> void:
	if next_spawn_index >= spawn_times.size():
		return
		
	current_time = audio_stream_player.get_playback_position()
	current_time += AudioServer.get_time_since_last_mix()
	current_time -= AudioServer.get_output_latency()

	if current_time >= spawn_times[next_spawn_index]:
		
		var time_since_last_spawn = current_time - last_spawn_time
		if time_since_last_spawn > spawn_cooldown:
			
			while next_spawn_index < spawn_times.size() and current_time >= spawn_times[next_spawn_index]:
				enemy_spawner.spawn_enemy(randi_range(0,2), randi_range(0,1)) 
				
				next_spawn_index += 1
				
				if next_spawn_index < spawn_times.size():
					var time_gap_to_next = spawn_times[next_spawn_index] - spawn_times[next_spawn_index - 1]
					
					if time_gap_to_next < spawn_cooldown:
						print_debug("Next beat is too close (", time_gap_to_next, "s). Waiting.")
						break
						
			last_spawn_time = current_time 
			
		else:
			print_debug("Skip: Cooldown active (Need ", spawn_cooldown, "s, only ", time_since_last_spawn, "s passed)")

func load_spawn_data() -> bool:
	var file = FileAccess.open(DATA_FILE_PATH, FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		push_error("Error opening file: %s" % DATA_FILE_PATH)
		return false
	
	var json_string = file.get_as_text()
	var json_result = JSON.parse_string(json_string)
	
	
	for i in json_result.size():
		var chosen_spawn_index := randi_range(0, 2)
		var distance_to_travel := distances[chosen_spawn_index] as float
		var time_needed := distance_to_travel / 10.0
		spawn_indexes.push_back(chosen_spawn_index)
		
		json_result[i] = json_result[i] * bpm_length - time_needed
		
		
	
		
	if json_result == null: # JSON.parse_string returns null on error
		push_error("Error parsing JSON string in %s" % DATA_FILE_PATH)
		return false
	
	if json_result is Array:
		spawn_times = json_result
		return true
	else:
		push_error("JSON data is not an array in %s" % DATA_FILE_PATH)
		return false


func _on_music_start_timer_timeout() -> void:
	audio_stream_player.play()
