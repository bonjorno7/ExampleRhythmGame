extends Control


func _ready() -> void:
	%Title.text = GameState.song.title
	%Artist.text = GameState.song.artist
	%Score/Value.text = str(GameState.score)
	%MaxCombo/Value.text = str(GameState.max_combo)
	%Great/Value.text = str(GameState.judge_great) + " (+" + str(GameState.judge_hold_hit) + ")"
	%Good/Value.text = str(GameState.judge_good)
	%Bad/Value.text = str(GameState.judge_bad)
	%Miss/Value.text = str(GameState.judge_miss) + " (+" + str(GameState.judge_hold_miss) + ")"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameState.goto_select()


func _on_back_pressed() -> void:
	GameState.goto_select()
