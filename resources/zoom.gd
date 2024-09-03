class_name Zoom
extends Resource

@export var layer: int = 0
@export var beat: float = 0.0
@export var value: float = 1.0
@export var curve: float = 1.0


func _init(layer_ := 0, beat_ := 0.0, value_ := 1.0, curve_ := 1.0) -> void:
	layer = layer_
	beat = beat_
	value = value_
	curve = curve_
