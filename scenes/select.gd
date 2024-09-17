extends Control


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		GameState.goto_menu()


func _on_overcast_pressed():
	GameState.goto_play(load("res://songs/overcast.tres"), 0)


func _on_abyssal_chronos_pressed():
	GameState.goto_play(load("res://songs/abyssal_chronos.tres"), 0)


func _on_back_pressed():
	GameState.goto_menu()
