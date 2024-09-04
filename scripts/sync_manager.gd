class_name SyncManager
extends Node

## Song to sync with. Does not update automatically if data is changed.
@export var song: Song: set = set_song

var time_audio: float = 0.0
var time_input: float = 0.0
var time_video: float = 0.0

var beat_audio: float = 0.0
var beat_input: float = 0.0
var beat_video: float = 0.0

var _items: Array[_Item] = []
var _time_index: int = 0
var _beat_index: int = 0


func set_song(value: Song) -> void:
	song = value

	_items.clear()
	_time_index = 0
	_beat_index = 0

	for tempo in song.tempos:
		_items.append(_Item.new(tempo.beat, tempo.value))
	if not _items.is_empty():
		_items[0].setup_first(song)
	for index in range(1, len(_items)):
		_items[index].setup_other(_items[index - 1])


func set_time(time: float) -> void:
	time_audio = time  # Audio is our source of truth.
	time_input = time_audio - Game.audio_offset  # Audio offset includes input latency.
	time_video = time_input + Game.video_offset  # Video offset includes input latency.

	beat_audio = get_beat(time_audio)
	beat_input = get_beat(time_input)
	beat_video = get_beat(time_video)


func set_beat(beat: float) -> void:
	set_time(get_time(beat))


func get_time(beat: float) -> float:
	if _items.is_empty():
		return beat

	# Find the closest segment. Linear search is fast because inputs are mostly sorted.
	while _time_index < len(_items) and beat > _items[_time_index].beat:
		_time_index += 1
	while _time_index > 0 and beat < _items[_time_index - 1].beat:
		_time_index -= 1

	# Handle cases before the first tempo change and after the last.
	if _time_index == 0 or _time_index == len(_items):
		var item := _items[0 if _time_index == 0 else -1]
		return item.time + (beat - item.beat) * (60.0 / item.value)

	# Interpolate to get the time at this beat.
	var start := _items[_time_index - 1]
	var end := _items[_time_index]
	var weight := inverse_lerp(start.beat, end.beat, beat)
	return lerpf(start.time, end.time, weight)


func get_beat(time: float) -> float:
	if _items.is_empty():
		return time

	# Find the closest segment. Linear search is fast because inputs are mostly sorted.
	while _beat_index < len(_items) and time > _items[_beat_index].time:
		_beat_index += 1
	while _beat_index > 0 and time < _items[_beat_index - 1].time:
		_beat_index -= 1

	# Handle cases before the first tempo change and after the last.
	if _beat_index == 0 or _beat_index == len(_items):
		var item := _items[0 if _beat_index == 0 else -1]
		return item.beat + (time - item.time) / (60.0 / item.value)

	# Interpolate to get the beat at this time.
	var start := _items[_beat_index - 1]
	var end := _items[_beat_index]
	var weight := inverse_lerp(start.time, end.time, time)
	return lerpf(start.beat, end.beat, weight)


class _Item:
	var beat: float
	var value: float

	var time: float

	func _init(beat_: float, value_: float) -> void:
		beat = beat_
		value = value_

	func setup_first(song: Song) -> void:
		time = song.offset + beat * (60.0 / value)

	func setup_other(prev: _Item) -> void:
		time = prev.time + (beat - prev.beat) * (60.0 / prev.value)
