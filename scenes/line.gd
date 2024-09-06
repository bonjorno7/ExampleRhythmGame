class_name LineObject
extends MeshInstance3D

var beat: float

var time: float
var location: float  # Different name because position is already taken.


func setup(beat_: float, sync_manager: SyncManager, view_layer: ViewLayer):
	beat = beat_

	time = sync_manager.get_time(beat)
	location = view_layer.get_position(time)


func update(view_layer: ViewLayer):
	position.z = GameState.scroll_speed * (view_layer.position - location) * view_layer.scale
