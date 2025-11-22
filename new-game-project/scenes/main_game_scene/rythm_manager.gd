extends Node

# --- EXTERNAL NODE REFERENCES (MUST BE CONFIGURED IN SCENE) ---
@onready var enemy_spawner: Node = $"../EnemySpawner"
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player_node: Node3D = $"../Player"      # Reference to your player's Node3D
var current_time := 0.0

# --- RHYTHM CONSTANTS & SEQUENCING ---
const BPM := 195.0
const TICK_LENGTH := 60.0 / BPM # Time in seconds per beat

# Sequence of travel times (in beats) for each successive enemy spawn event.
# Lower number = faster speed / higher difficulty.
# Example sequence: 4 beats, 4 beats, 3 beats, 3 beats, 2 beats (very fast), then repeats.
var travel_intervals: Array[int] = [5, 4, 3, 3, 2, 4, 3, 1, 1]
var note_sequence_index: int = 0
# Placeholder for the type of enemy to spawn
# --- ENEMY SPAWNING ---
var beat_interval := 8 # The number of beats between each spawn *event*
# This tracks the time the enemy should ARRIVE at the player.
var next_arrival_time := 0.0 

func _ready() -> void:
	# Initialize RandomNumberGenerator for random spawn selection
	randomize() 

	# Safety check for essential nodes
	if not player_node or not enemy_spawner:
		printerr("Rhythm Manager setup error: Missing 'Player' or 'EnemySpawner' nodes in the scene.")
		set_process(false)
		return
		
	audio_stream_player.play()
	# Set the time of the first enemy's arrival beat
	next_arrival_time = current_time + (beat_interval * TICK_LENGTH)

# Removed the _get_random_unique_indices helper function as we only need one index now.

func _process(_delta: float) -> void:
	# Adjust for audio latency for the most accurate timing
	current_time = audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix()
	current_time -= AudioServer.get_output_latency()
	
	# Get the required travel time for the current sequence step
	var current_travel_interval: int = travel_intervals[note_sequence_index]
	var required_travel_time: float = current_travel_interval * TICK_LENGTH
	
	# Calculate the exact time the enemies must be spawned: Arrival Time - Travel Time
	var next_spawn_time = next_arrival_time - required_travel_time
	
	if current_time >= next_spawn_time:
		# 1. Advance the arrival time and sequence index for the *next* spawn event
		next_arrival_time += (beat_interval * TICK_LENGTH)
		note_sequence_index = (note_sequence_index + 1) % travel_intervals.size()
		
		var target_pos = player_node.global_position
		
		# 2. Select a single random spawn point
		var max_index = enemy_spawner.spawnpoints.size()
		var spawn_index: int = -1
		
		if max_index > 0:
			spawn_index = randi_range(0, max_index - 1)
		
		if spawn_index != -1:
			# 3. Spawn a single enemy
			# Get the spawn position from the Spawner based on the chosen index
			var spawn_pos = enemy_spawner.get_spawn_position(spawn_index)
			
			# Calculate speed based on this specific distance and the required travel time
			var required_speed = _calculate_required_speed(spawn_pos, required_travel_time)
			
			# Call the spawner with the index, calculated speed, target, and enemy type
			enemy_spawner.spawn_enemy(spawn_index, required_speed, target_pos, randi_range(0, 1))
		else:
			printerr("Rhythm Manager: Cannot spawn, no valid spawn points available.")


## Calculates the speed required for the enemy to travel from a given spawn point
## to the player's position in exactly required_travel_time seconds.
func _calculate_required_speed(spawn_pos: Vector3, required_travel_time: float) -> float:
	# 1. Define Goal Position
	var goal_pos: Vector3 = player_node.global_position

	# 2. Calculate the total straight-line distance (D)
	var total_distance: float = spawn_pos.distance_to(goal_pos)
	
	# 3. Calculate the required speed (S = D / T)
	if required_travel_time <= 0:
		return 0.0 # Prevent division by zero
		
	var required_speed: float = total_distance / required_travel_time
	
	return required_speed
