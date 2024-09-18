extends Control
# TODO: Refactor the code and reduce the number of comments.

const NoteScene := preload("res://scenes/note.tscn")
const LineScene := preload("res://scenes/line.tscn")

var notes: Array[NoteObject] = []
var notes_to_draw: Array[NoteObject]
var notes_to_draw_index: int
var notes_to_hit: Array[NoteObject]
var notes_to_hit_index: int

var lines: Array[LineObject] = []
var lines_to_draw: Array[LineObject]
var lines_to_draw_index: int

var button_states: Array[ButtonState]

@onready var music_player: MusicPlayer = %MusicPlayer
@onready var sync_manager: SyncManager = %SyncManager
@onready var view_layers: Array[ViewLayer]


func _ready() -> void:
	# One button per lane.
	for index in range(4):
		button_states.append(ButtonState.new())

	# Workaround for array typing issue.
	view_layers.assign(sync_manager.get_children())

	# Setup music sync stuff.
	music_player.stream = GameState.song.audio
	sync_manager.setup(GameState.song)
	for layer in view_layers:
		layer.setup(GameState.chart)

	# Create and pre-process notes.
	for note in GameState.chart.notes:
		var instance: NoteObject = NoteScene.instantiate()
		instance.setup(note, sync_manager, view_layers[note.layer])
		notes.append(instance)

	# TODO: Use song length and tempo to generate beat lines.
	for beat in range(-100, 1000):
		var instance: LineObject = LineScene.instantiate()
		instance.setup(beat, sync_manager, view_layers[0])
		lines.append(instance)

	# Reset statistics.
	GameState.score = 0
	GameState.max_score = 0
	GameState.combo = 0
	GameState.max_combo = 0

	GameState.judge_great = 0
	GameState.judge_good = 0
	GameState.judge_bad = 0
	GameState.judge_miss = 0
	GameState.judge_hold_hit = 0
	GameState.judge_hold_miss = 0

	# Calculate max score, divide by this to get display score.
	for note in notes:
		var ticks := 1 + note.hold_end - note.hold_tick
		GameState.max_score += 100 + ticks * 10

	# Give the player 2 seconds to get ready before the song starts.
	music_player.start(-2.0)

	# Clear judge/combo default text on the first frame.
	# They start with placeholder text to avoid a lagspike on the first note.
	await get_tree().process_frame
	%Judge.text = ""
	%Combo.text = ""


func _process(_delta: float) -> void:
	sync_manager.update()
	for layer in view_layers:
		layer.update()

	# Update button states.
	for button_state in button_states:
		if sync_manager.time_input - 0.100 > button_state.released:
			button_state.pressed = false

	# Add notes to draw.
	while notes_to_draw_index < len(notes):
		var note := notes[notes_to_draw_index]
		if sync_manager.time_video + 10.0 < note.time_start:
			break

		add_child(note)
		notes_to_draw.append(note)
		notes_to_draw_index += 1

	# Remove notes that are no longer visible.
	for index in range(len(notes_to_draw) - 1, -1, -1):
		var note := notes_to_draw[index]
		if sync_manager.time_video - 1.0 > note.time_end:
			notes_to_draw.remove_at(index)
			note.queue_free()

	# Update note positions.
	for note in notes_to_draw:
		note.update(view_layers[note.layer])

	# Add beat lines to draw.
	while lines_to_draw_index < len(lines):
		var line := lines[lines_to_draw_index]
		if sync_manager.time_video + 10.0 < line.time:
			break

		add_child(line)
		lines_to_draw.append(line)
		lines_to_draw_index += 1

	# Remove beat lines that are no longer visible.
	for index in range(len(lines_to_draw) - 1, -1, -1):
		var line := lines_to_draw[index]
		if sync_manager.time_video - 1.0 > line.time:
			lines_to_draw.remove_at(index)
			line.queue_free()

	# Update beat line positions.
	for line in lines_to_draw:
		line.update(view_layers[0])

	# Add notes for input handling.
	while notes_to_hit_index < len(notes):
		var note := notes[notes_to_hit_index]
		if sync_manager.time_input + GameState.TIME_BAD < note.time_start:
			break

		notes_to_hit.append(note)
		notes_to_hit_index += 1

	# Remove notes that can no longer be hit.
	for index in range(len(notes_to_hit) - 1, -1, -1):
		var note := notes_to_hit[index]

		# When you miss a hold note it starts giving you misses every tick.
		if sync_manager.time_input - GameState.TIME_BAD > note.time_start:
			if not note.hold_process:
				note.hold_process = true
				%Judge.text = "(╥﹏╥)"
				GameState.combo = 0
				GameState.judge_miss += 1

		# When you miss a regular note, or a hold note is completely done, it's removed.
		if sync_manager.time_input - GameState.TIME_BAD > note.time_end:
			notes_to_hit.remove_at(index)

	# Handle hold note ticks.
	for note in notes_to_hit:
		if note.hold_process:
			# Do a tick for every quarter beat from after the start,
			# up to and including the end of the hold note.
			var tick := floori(sync_manager.beat_input * 4.0)
			while tick >= note.hold_tick and note.hold_tick <= note.hold_end:
				note.hold_tick += 1

				# Not only do you have to be holding the button, it won't count
				# unless you pressed it within the window for this note body.
				if note.hold_hit and button_states[note.lane].pressed:
					%Judge.text = "⸜(｡˃ ᵕ ˂ )⸝♡"
					GameState.score += 10
					GameState.combo += 1
					GameState.max_combo = maxi(GameState.max_combo, GameState.combo)
					GameState.judge_hold_hit += 1
				else:
					%Judge.text = "(╥﹏╥)"
					GameState.combo = 0
					GameState.judge_hold_miss += 1

	# Update UI stuff.
	%FPS.text = str(Engine.get_frames_per_second())
	%Offset.text = String.num(music_player.get_time_offset() * 1000.0, 6).pad_decimals(6)
	%Score.text = str(roundi(GameState.score * 1_000_000.0 / GameState.max_score))
	%MaxCombo.text = str(GameState.max_combo)

	# Update combo counter.
	if GameState.combo > 0:
		%Combo.text = str(GameState.combo)
	else:
		%Combo.text = ""


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameState.goto_result()

	elif event.is_action_pressed("change_camera"):
		# This works because making one camera current makes the other one not current,
		# and making one camera not current makes the other one current.
		%CameraPerspective.current = %CameraOrthographic.current

	else:
		for action in range(4):
			if event.is_action_pressed(["button_1", "button_2", "button_3", "button_4"][action]):
				# If the button was just pressed, use infinity so it doesn't release on its own.
				button_states[action].pressed = true
				button_states[action].released = INF

				for note in notes_to_hit:
					if note.lane == action:
						if note.length == 0.0:
							if absf(note.time_start - sync_manager.time_input) < GameState.TIME_GREAT:
								%Judge.text = "⸜(｡˃ ᵕ ˂ )⸝♡"
								GameState.score += 100
								GameState.combo += 1
								GameState.max_combo = maxi(GameState.max_combo, GameState.combo)
								GameState.judge_great += 1

							elif absf(note.time_start - sync_manager.time_input) < GameState.TIME_GOOD:
								%Judge.text = "ദ്ദി ( ᵔ ᗜ ᵔ )"
								GameState.score += 50
								GameState.combo += 1
								GameState.max_combo = maxi(GameState.max_combo, GameState.combo)
								GameState.judge_good += 1

							else:  # Implicitly this is within 200ms, because otherwise the note wouldn't be in notes_to_hit.
								%Judge.text = "\"( - ⌓ - )"
								GameState.combo = 0
								GameState.judge_bad += 1

							# Non-hold notes can be removed immediately.
							notes_to_draw.erase(note)
							notes_to_hit.erase(note)
							note.queue_free()

							break  # An input can only hit one note per lane.

						elif not note.hold_hit:
							note.hold_hit = true  # This is to make sure you can't just keep holding the button from the previous note.
							if not note.hold_process:
								note.hold_process = true  # On hit we always start processing, but it can also start processing on miss.

								if absf(note.time_start - sync_manager.time_input) < GameState.TIME_GREAT:
									%Judge.text = "⸜(｡˃ ᵕ ˂ )⸝♡"
									GameState.score += 100
									GameState.combo += 1
									GameState.max_combo = maxi(GameState.max_combo, GameState.combo)
									GameState.judge_great += 1

								elif absf(note.time_start - sync_manager.time_input) < GameState.TIME_GOOD:
									%Judge.text = "ദ്ദി ( ᵔ ᗜ ᵔ )"
									GameState.score += 50
									GameState.combo += 1
									GameState.max_combo = maxi(GameState.max_combo, GameState.combo)
									GameState.judge_good += 1

								else:  # Implicitly this is within 200ms, because otherwise the note wouldn't be in notes_to_hit.
									%Judge.text = "\"( - ⌓ - )"
									GameState.combo = 0
									GameState.judge_bad += 1

								break  # An input can only hit one note per lane.

			elif event.is_action_released(["button_1", "button_2", "button_3", "button_4"][action]):
				# Instead of immediately considering the button released, we wait 100ms.
				# That way if you have a hardware issue it won't immediately miss hold notes.
				# It also means you can release hold notes 100ms too early, which seems fair to me.
				button_states[action].released = sync_manager.time_input


class ButtonState:
	var pressed: bool = false  # Whether hold notes should treat this button as pressed.
	var released: float = -INF  # The time at which the button was physically released.
