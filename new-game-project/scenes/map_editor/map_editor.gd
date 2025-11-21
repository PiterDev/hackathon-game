extends Control

var audio_position := 0.0: 
	set(value):
		$HSlider.value = audio_position / audio_length
		audio_position = value
var audio_length := 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !$AudioStreamPlayer.playing:
		return
	var new_audio_position = $AudioStreamPlayer.get_playback_position() + AudioServer.get_time_since_last_mix() as float
	var new_audio_length = $AudioStreamPlayer.stream.get_length() as float
	if new_audio_position != audio_position:
		audio_position = new_audio_position
	if new_audio_length != audio_length:
		audio_length = new_audio_length


func _on_play_button_pressed() -> void:
	$AudioStreamPlayer.play()


func _on_pause_button_pressed() -> void:
	$AudioStreamPlayer.stop()


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		$AudioStreamPlayer.seek($HSlider.value * audio_length)
