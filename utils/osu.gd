class_name OSU


static func load(path: String) -> Song:
	var song := Song.new()
	var chart := Chart.new()

	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text(true)
	file.close()

	var lines := content.split("\n")
	var osu_chart := _Chart.new()
	var mode := "[None]"

	for line in lines:
		if line.is_empty():
			pass  # Empty lines should not get parsed.

		elif line in ["[General]", "[Metadata]", "[TimingPoints]", "[HitObjects]"]:
			mode = line

		elif mode == "[General]":
			if line.begins_with("AudioFilename: "):
				song.audio = load("res://songs/" + line.trim_prefix("AudioFilename: "))

		elif mode == "[Metadata]":
			if line.begins_with("Title:"):
				song.title = line.trim_prefix("Title:")
			elif line.begins_with("Artist:"):
				song.artist = line.trim_prefix("Artist:")

		elif mode == "[TimingPoints]":
			if int(line.get_slice(",", 6)):
				osu_chart.tempos.append(_Tempo.new(line))
			else:
				osu_chart.speeds.append(_Speed.new(line))

		elif mode == "[HitObjects]":
			osu_chart.notes.append(_Note.new(line))

	osu_chart.setup()  # Convert time values to beat values.

	for tempo in osu_chart.tempos:
		song.tempos.append(Tempo.new(tempo.beat, tempo.value))
	for speed in osu_chart.speeds:
		chart.speeds.append(Speed.new(0, speed.beat, speed.value))
	for note in osu_chart.notes:
		chart.notes.append(Note.new(0, note.lane, note.beat, note.length))

	song.offset = osu_chart.tempos[0].time  # For offset we use the time of the first tempo.
	chart.speeds.push_front(Speed.new(0, 0.0, 1.0))  # Make sure we start at default speed.

	song.charts.append(chart)
	return song


class _Chart:
	var tempos: Array[_Tempo] = []
	var speeds: Array[_Speed] = []
	var notes: Array[_Note] = []

	var index := 0  # Used for time to beat conversion.

	func setup() -> void:
		for i in range(1, len(tempos)):
			tempos[i].setup(tempos[i - 1])
		for speed in speeds:
			speed.setup(self)
		for note in notes:
			note.setup(self)

	func get_beat(time: float) -> float:
		if tempos.is_empty():
			return time

		# Find the closest segment. Linear search is fast because inputs are mostly sorted.
		while index < len(tempos) and time > tempos[index].time:
			index += 1
		while index > 0 and time < tempos[index - 1].time:
			index -= 1

		# Handle cases before the first tempo change and after the last.
		if index == 0 or index == len(tempos):
			var item := tempos[0 if index == 0 else -1]
			return item.beat + (time - item.time) / (60.0 / item.value)

		# Interpolate to get the beat at this time.
		var start := tempos[index - 1]
		var end := tempos[index]
		var weight := inverse_lerp(start.time, end.time, time)
		return lerpf(start.beat, end.beat, weight)


class _Tempo:
	var time: float
	var value: float

	var beat: float = 0.0  # Default value is used for the first speed change.

	func _init(line: String = "") -> void:
		var values := line.split(",", false)
		if values.is_empty():
			return

		time = float(values[0]) / 1000.0
		value = 60_000.0 / float(values[1])  # Tempo is stored in milliseconds per beat.

	func setup(prev: _Tempo) -> void:
		# Snap to whole beats to avoid rounding errors.
		beat = roundf(prev.beat + (time - prev.time) / (60.0 / prev.value))


class _Speed:
	var time: float
	var value: float

	var beat: float

	func _init(line: String = "") -> void:
		var values := line.split(",", false)
		if values.is_empty():
			return

		time = float(values[0]) / 1000.0
		value = -100.0 / float(values[1])  # Speed is stored as negative inverse percentage.

	func setup(osu_chart: _Chart) -> void:
		# Snap to 12th beats to avoid rounding errors.
		beat = roundf(osu_chart.get_beat(time) * 12.0) / 12.0


class _Note:
	var lane: int
	var time: float
	var end_time: float

	var beat: float
	var length: float

	func _init(line: String = "") -> void:
		var values := line.split(",", false)
		if values.is_empty():
			return

		lane = [64, 192, 320, 448].find(int(values[0]))  # Lane is stored in pixels.
		time = float(values[2]) / 1000.0

		if int(values[3]) & 128:  # The seventh bit marks it as a hold note.
			end_time = float(values[5].get_slice(":", 0)) / 1000.0
		else:
			end_time = time

	func setup(osu_chart: _Chart) -> void:
		# Snap to 12th beats to avoid rounding errors.
		beat = roundf(osu_chart.get_beat(time) * 12.0) / 12.0
		length = roundf((osu_chart.get_beat(end_time) - osu_chart.get_beat(time)) * 12.0) / 12.0
