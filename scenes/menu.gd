extends Control


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_select_pressed():
	GameState.goto_select()


func _on_drift_pressed():
	GameState.goto_drift()


func _on_options_pressed():
	GameState.goto_options()


func _on_exit_pressed():
	get_tree().quit()
