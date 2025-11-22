extends Node

@onready var enemy_spawner: Node = $"../EnemySpawner"
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var current_time := 0.0

const BPM := 140.0
const TICK_LENGTH := 60.0 / BPM
const PROGRESSION_RATE := 0.2 
const MIN_INTERVAL := 2.0

var enemy_interval := 6.0
var _next_tick := 0.0

func _ready() -> void:
	audio_stream_player.play()
	_next_tick = current_time + (enemy_interval * TICK_LENGTH)

func _process(delta: float) -> void:
	enemy_interval = max(MIN_INTERVAL, enemy_interval - PROGRESSION_RATE * delta)
	current_time = audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix()
	current_time -= AudioServer.get_output_latency()
	
	if current_time >= _next_tick:
		_next_tick = current_time + (enemy_interval * TICK_LENGTH)
		enemy_spawner.spawn_enemy(randi_range(0,2), randi_range(0,1))
