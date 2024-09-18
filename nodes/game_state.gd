## Autoload GameState
extends Node

const TIME_GREAT: float = 0.050
const TIME_GOOD: float = 0.100
const TIME_BAD: float = 0.200

var fullscreen: bool = false
var volume: float = 0.5
var audio_offset: float = 0.000
var video_offset: float = 0.000
var scroll_speed: float = 8.000

var song: Song
var chart: Chart
var score: int
var max_score: int
var combo: int
var max_combo: int

var judge_great: int
var judge_good: int
var judge_bad: int
var judge_miss: int
var judge_hold_hit: int
var judge_hold_miss: int


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused


func goto_menu() -> void:
	_goto_file_deferred.call_deferred("res://scenes/menu.tscn")


func goto_select() -> void:
	_goto_file_deferred.call_deferred("res://scenes/select.tscn")


func goto_play(song_: Song, chart_index: int) -> void:
	song = song_
	chart = song.charts[chart_index]
	_goto_file_deferred.call_deferred("res://scenes/play.tscn")


func goto_drift() -> void:
	_goto_file_deferred.call_deferred("res://scenes/drift.tscn")


func goto_options() -> void:
	_goto_file_deferred.call_deferred("res://scenes/options.tscn")


func _goto_file_deferred(path: String) -> void:
	get_tree().current_scene.free()
	var scene: Node = load(path).instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
