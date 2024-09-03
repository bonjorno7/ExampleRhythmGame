class_name Tempo
extends Resource

@export var beat: float = 0.0
@export var value: float = 60.0


func _init(beat_ := 0.0, value_ := 60.0) -> void:
	beat = beat_
	value = value_
