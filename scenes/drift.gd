extends Control

const BPM := 120.0
const BPS := BPM / 60.0

var offset_array: PackedVector2Array
var offset_index: int
var next_beat := 0


func _ready() -> void:
	offset_array.resize(300)
	%BGM.start()


func _physics_process(_delta: float) -> void:
	var time: float = %BGM.get_time_engine()
	offset_array[offset_index].x = %BGM.get_time_player() - time
	offset_array[offset_index].y = %BGM.get_time_smooth() - time
	offset_index = (offset_index + 1) % len(offset_array)


func _process(_delta: float) -> void:
	if %BGM.get_time_smooth() + AudioServer.get_time_to_next_mix() >= next_beat / BPS:
		queue_redraw()
		%Hit.play()
		next_beat += 1

	%FPS.text = str(roundi(Engine.get_frames_per_second()))
	%Time.text = String.num(%BGM.get_time_smooth(), 6).pad_decimals(6)
	%Drift.text = String.num(%BGM.get_time_offset() * 1000.0, 6).pad_decimals(6)


func _draw() -> void:
	draw_set_transform(Vector2(0.0, size.y * 0.5))
	draw_line(Vector2(0.0, 0.0), Vector2(size.x, 0.0), Color.BLACK, 2)

	for index in range(offset_index, len(offset_array) + offset_index):
		var x := (index - offset_index) * 10.0
		if x > size.x:
			break

		index %= len(offset_array)
		draw_line(Vector2(x, size.y * 0.5), Vector2(x, size.y * -0.5), Color.BLACK, 2)
		draw_circle(Vector2(x, offset_array[index].x * -5000.0), 2, Color.ORANGE_RED)
		draw_circle(Vector2(x, offset_array[index].y * -5000.0), 2, Color.DEEP_SKY_BLUE)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameState.goto_menu()


func _on_back_pressed() -> void:
	GameState.goto_menu()
