## Autoload Game
extends Node

var fullscreen: bool = false
var volume: float = 0.5
var audio_offset: float = 0.000
var video_offset: float = 0.000
var scroll_speed: float = 8.000


func goto_menu() -> void:
	_goto_file_deferred.call_deferred("res://scenes/menu.tscn")


func goto_play() -> void:
	pass  # TODO: Add play scene.


func goto_drift() -> void:
	_goto_file_deferred.call_deferred("res://scenes/drift.tscn")


func goto_options() -> void:
	_goto_file_deferred.call_deferred("res://scenes/options.tscn")


func _goto_file_deferred(path: String) -> void:
	get_tree().current_scene.free()
	var scene: Node = load(path).instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
