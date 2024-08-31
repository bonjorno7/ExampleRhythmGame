class_name Music
extends AudioStreamPlayer

@export var buffer: int = 100  ## Number of physics frames to smooth across.

var _play_later: bool  # Start audio playback after a given delay.
var _time_start: float  # Used to determine time relative to playback.
var _offset_array: PackedFloat64Array  # Rotating array of offsets.
var _offset_index: int  # Oldest element in the array of offsets.
var _offset_sum: float  # Sum of offsets, used to calculate average.
var _offset_average: float  # Average offset, used to adjust time.


func _physics_process(_delta: float) -> void:
	if playing:
		_offset_sum -= _offset_array[_offset_index]
		_offset_array[_offset_index] = get_time_engine() - get_time_player()
		_offset_sum += _offset_array[_offset_index]

		_offset_average = _offset_sum / len(_offset_array)
		_offset_index = (_offset_index + 1) % len(_offset_array)

	elif _play_later and get_time_engine() >= -AudioServer.get_time_to_next_mix():
		_play_later = false
		play()


## Start playing at a given time, negative numbers start after a delay.
func start(time: float = 0.0) -> void:
	_time_start = Time.get_ticks_usec() / 1_000_000.0 - time
	_play_later = time < 0.0

	_offset_array.clear()
	_offset_array.resize(buffer)
	_offset_index = 0
	_offset_sum = 0.0
	_offset_average = 0.0

	if not _play_later:
		play(time)


## Time relative to playback start.
func get_time_engine() -> float:
	return Time.get_ticks_usec() / 1_000_000.0 - _time_start


## Audio playback position plus time since last mix.
func get_time_player() -> float:
	return get_playback_position() + AudioServer.get_time_since_last_mix()


## Time adjusted to compensate for audio drift.
func get_time_synced() -> float:
	return get_time_engine() - get_time_offset()


## Positive values mean audio is running slow.
func get_time_offset() -> float:
	return _offset_average
