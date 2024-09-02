class_name Song

var title: String
var artist: String
var offset: float
var tempos: Array[Tempo] = []


class Tempo:
	var beat: float
	var value: float

	func _init(beat_ := 0.0, value_ := 120.0) -> void:
		beat = beat_
		value = value_
