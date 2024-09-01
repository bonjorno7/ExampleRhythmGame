## Autoload Game
extends Node

var fullscreen := false
var volume := 1.0
var audio_offset := 0.000
var video_offset := 0.000
var scroll_speed := 1.000

var song: Song
var chart: Chart
var timing: Timing
var layers: Array[Layer]


func _init() -> void:
	timing = Timing.new()

	for index in range(8):
		layers.append(Layer.new(index))


func setup() -> void:
	timing.setup()

	for layer in layers:
		layer.setup()


func update(time: float) -> void:
	timing.update(time)

	for layer in layers:
		layer.update(timing.time_video)
