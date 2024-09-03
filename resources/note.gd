class_name Note
extends Resource

@export var layer: int = 0
@export var lane: int = 0
@export var beat: float = 0.0
@export var length: float = 0.0


func _init(layer_ := 0, lane_ := 0, beat_ := 0.0, length_ := 0.0) -> void:
	layer = layer_
	lane = lane_
	beat = beat_
	length = length_
