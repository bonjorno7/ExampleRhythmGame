extends Control


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameState.goto_menu()


func _on_overcast_pressed() -> void:
	GameState.goto_play(load("res://songs/overcast.tres"), 0)


func _on_abyssal_chronos_pressed() -> void:
	GameState.goto_play(load("res://songs/abyssal_chronos.tres"), 0)


func _on_back_pressed() -> void:
	GameState.goto_menu()
