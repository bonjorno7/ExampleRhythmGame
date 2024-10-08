extends Control

enum CalibrationMode { NONE, AUDIO, VIDEO }

const BPM := 120.0
const BPS := BPM / 60.0

var calibration_mode: CalibrationMode
var calibration_hits: PackedFloat64Array


func _ready() -> void:
	%Volume.value = GameState.volume
	%AudioOffset.value = GameState.audio_offset
	%VideoOffset.value = GameState.video_offset
	%ScrollSpeed.value = GameState.scroll_speed


func _physics_process(_delta: float) -> void:
	if calibration_mode != CalibrationMode.NONE and len(calibration_hits) >= 12:
		%Music.stop()

		%UI.show()
		%AudioCalibration.hide()
		%VideoCalibration.hide()

		var sum := 0.0
		for hit in calibration_hits:
			sum += hit

		if calibration_mode == CalibrationMode.AUDIO:
			%AudioOffset.value = sum / len(calibration_hits)
		elif calibration_mode == CalibrationMode.VIDEO:
			%VideoOffset.value = sum / len(calibration_hits)

		calibration_mode = CalibrationMode.NONE


func _process(_delta: float) -> void:
	if calibration_mode == CalibrationMode.VIDEO:
		# Not using latency compensation because the goal is to find the latency.
		var cycle: float = %Music.get_time_smooth() * BPS * 0.25

		%VideoCalibration/Ball1.position.y = sqrt(absf(sin(PI * (cycle - 0.00)))) * -200.0
		%VideoCalibration/Ball2.position.y = sqrt(absf(sin(PI * (cycle - 0.25)))) * -200.0
		%VideoCalibration/Ball3.position.y = sqrt(absf(sin(PI * (cycle - 0.50)))) * -200.0
		%VideoCalibration/Ball4.position.y = sqrt(absf(sin(PI * (cycle - 0.75)))) * -200.0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameState.goto_menu()

	for action in ["button_1", "button_2", "button_3", "button_4"]:
		if event.is_action_pressed(action):
			# Not using latency compensation because the goal is to find the latency.
			var time: float = %Music.get_time_smooth()
			var target := floorf((time + 0.150) * BPS) / BPS
			calibration_hits.append(time - target)
			break


func _on_back_pressed() -> void:
	GameState.goto_menu()


func _on_toggle_fullscreen_pressed() -> void:
	GameState.fullscreen = not GameState.fullscreen

	if GameState.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_volume_changed(value: float) -> void:
	GameState.volume = value
	%Volume/Value.text = String.num(value * 100, 1) + " %"

	AudioServer.set_bus_volume_db(0, remap(value, 0, 1, -48, 0))
	AudioServer.set_bus_mute(0, is_zero_approx(value))


func _on_audio_offset_changed(value: float) -> void:
	GameState.audio_offset = value
	%AudioOffset/Value.text = str(roundi(value * 1000)) + " ms"


func _on_video_offset_changed(value: float) -> void:
	GameState.video_offset = value
	%VideoOffset/Value.text = str(roundi(value * 1000)) + " ms"


func _on_scroll_speed_changed(value: float) -> void:
	GameState.scroll_speed = value
	%ScrollSpeed/Value.text = String.num(value, 2) + " x"


func _on_calibrate_audio_offset_pressed() -> void:
	# Video offset calibration mutes the audio, so we reset it here.
	%Music.volume_db = 0
	%Music.start()

	%UI.hide()
	%AudioCalibration.show()

	calibration_mode = CalibrationMode.AUDIO
	calibration_hits.clear()


func _on_calibrate_video_offset_pressed() -> void:
	# The user needs to time visually, so we mute the audio.
	%Music.volume_db = -80
	%Music.start()

	%UI.hide()
	%VideoCalibration.show()

	calibration_mode = CalibrationMode.VIDEO
	calibration_hits.clear()


func _play_click() -> void:
	# Using a 50ms debounce timer so the sound isn't spammed to much.
	if %Click/Debounce.is_stopped() and calibration_mode == CalibrationMode.NONE:
		%Click/Debounce.start()
		%Click.play()
