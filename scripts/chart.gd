class_name Chart

var tempos: Array[Tempo] = []
var speeds: Array[Speed] = []
var zooms: Array[Zoom] = []
var notes: Array[Note] = []


class Tempo:
	var beat: float
	var value: float

	func _init(beat_ := 0.0, value_ := 120.0) -> void:
		beat = beat_
		value = value_


class Speed:
	var layer: int
	var beat: float
	var value: float
	var curve: float

	func _init(layer_ := 0, beat_ := 0.0, value_ := 1.0, curve_ := 0.0) -> void:
		layer = layer_
		beat = beat_
		value = value_
		curve = curve_


class Zoom:
	var layer: int
	var beat: float
	var value: float
	var curve: float

	func _init(layer_ := 0, beat_ := 0.0, value_ := 1.0, curve_ := 1.0) -> void:
		layer = layer_
		beat = beat_
		value = value_
		curve = curve_


class Note:
	var layer: int
	var lane: int
	var beat: float
	var length: float

	func _init(layer_ := 0, lane_ := 0, beat_ := 0.0, length_ := 0.0) -> void:
		layer = layer_
		lane = lane_
		beat = beat_
		length = length_
