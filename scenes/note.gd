class_name NoteObject
extends Node3D

var layer: int
var lane: int
var beat: float
var length: float

var time_start: float
var time_end: float
var position_start: float
var position_end: float

var hold_hit: bool
var hold_process: bool  # This is enabled by hitting the note or waiting beyond the start window.
var hold_tick: int  # The current tick (quarter of a beat).
var hold_end: int  # The last tick (inclusive).

@onready var head: MeshInstance3D = %Head
@onready var tail: MeshInstance3D = %Tail
@onready var body: MeshInstance3D = %Body


func _ready():
	if length <= 0.0:
		# I could make a separate scene, but I think just removing the unused nodes works fine here.
		tail.queue_free()
		body.queue_free()


func setup(note: Note, sync_manager: SyncManager, view_layer: ViewLayer):
	layer = note.layer
	lane = note.lane
	beat = note.beat
	length = note.length

	time_start = sync_manager.get_time(beat)
	time_end = sync_manager.get_time(beat + length)
	position_start = view_layer.get_position(time_start)
	position_end = view_layer.get_position(time_end)

	hold_hit = false
	hold_process = false
	hold_tick = ceili(beat * 4.0 + 0.5)  # Start half a beat late because we don't include the head.
	hold_end = floori((beat + length) * 4.0)

	position.x = [-0.75, -0.25, 0.25, 0.75][note.lane]


func update(view_layer: ViewLayer):
	head.position.z = GameState.scroll_speed * (view_layer.position - position_start) * view_layer.scale

	if length > 0.0:
		tail.position.z = GameState.scroll_speed * (view_layer.position - position_end) * view_layer.scale
		body.position.z = head.position.z
		body.scale.z = head.position.z - tail.position.z
