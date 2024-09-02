## Autoload Game
extends Node

var fullscreen: bool = false
var volume: float = 0.5
var audio_offset: float = 0.000
var video_offset: float = 0.000
var scroll_speed: float = 1.000

var song: Song
var chart: Chart
var timing: Timing
var layers: Array[Layer]


func _init() -> void:
	timing = Timing.new()

	for index in range(8):
		layers.append(Layer.new(index))


func setup() -> void:
	timing.setup(song)

	for layer in layers:
		layer.setup(chart, timing)


func update(time: float) -> void:
	timing.update(time)

	for layer in layers:
		layer.update(timing.time_video)
