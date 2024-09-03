extends Control

# TODO: Use Song and Timing instead of hardcoding BPM.
const BPM := 120.0
const BPS := BPM / 60.0

var offset_array: PackedVector2Array
var offset_index: int
var next_beat := 0

@onready var bgm: Music = %BGM
@onready var hit: AudioStreamPlayer = %Hit


func _ready():
	offset_array.resize(300)
	bgm.start()


func _physics_process(_delta: float):
	var time := bgm.get_time_engine()
	offset_array[offset_index].x = bgm.get_time_player() - time
	offset_array[offset_index].y = bgm.get_time_synced() - time
	offset_index = (offset_index + 1) % len(offset_array)


func _process(_delta: float):
	if bgm.get_time_synced() * BPS >= float(next_beat) - AudioServer.get_time_to_next_mix():
		queue_redraw()
		hit.play()
		next_beat += 1

	$FPS.text = str(roundi(Engine.get_frames_per_second()))
	$Time.text = String.num(bgm.get_time_synced(), 6).pad_decimals(6)
	$Drift.text = String.num(bgm.get_time_offset() * 1000.0, 6).pad_decimals(6)


func _draw():
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


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		Game.goto_menu()


func _on_back_pressed():
	Game.goto_menu()
