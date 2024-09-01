extends Control


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/play.tscn")


func _on_drift_pressed():
	get_tree().change_scene_to_file("res://scenes/drift.tscn")


func _on_options_pressed():
	get_tree().change_scene_to_file("res://scenes/options.tscn")


func _on_exit_pressed():
	get_tree().quit()
