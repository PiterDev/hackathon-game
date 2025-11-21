extends Node

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var current_time := 0.0

const BPM := 195.0
const TICK_LENGTH := 60.0 / BPM

# 200 ticks per minute = 3 per second
var enemy_interval := 9
var next_tick := 0.0

func _ready() -> void:
	#current_time = audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix()
	audio_stream_player.play()
	next_tick = current_time + (enemy_interval * TICK_LENGTH)

func _process(_delta: float) -> void:
	current_time = audio_stream_player.get_playback_position() + AudioServer.get_time_since_last_mix()
	current_time -= AudioServer.get_output_latency()
	print(current_time, " ", next_tick)
	if current_time >= next_tick:
		next_tick = current_time + (enemy_interval * TICK_LENGTH)
