extends Control


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		GameState.goto_menu()


func _on_overcast_pressed():
	GameState.song = load("res://songs/overcast.tres")
	GameState.chart = GameState.song.charts[0]
	GameState.goto_play()


func _on_abyssal_chronos_pressed():
	GameState.song = load("res://songs/abyssal_chronos.tres")
	GameState.chart = GameState.song.charts[0]
	GameState.goto_play()


func _on_back_pressed():
	GameState.goto_menu()
