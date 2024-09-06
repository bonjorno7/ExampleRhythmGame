class_name KSH


static func load(path: String) -> Song:
	var song := Song.new()
	var chart := Chart.new()

	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text(true)
	file.close()

	var lines := content.split("\n")
	var measures: Array[PackedStringArray] = []
	var hold_notes: Array[Note] = [null, null, null, null]

	for line in lines:
		if line.begins_with("--"):
			measures.append(PackedStringArray())

		elif measures.is_empty():
			if line.begins_with("title="):
				song.title = line.trim_prefix("title=")
			elif line.begins_with("artist="):
				song.artist = line.trim_prefix("artist=")
			elif line.begins_with("m="):
				song.audio = load("res://songs/" + line.trim_prefix("m="))
			elif line.begins_with("o="):
				song.offset = float(line.trim_prefix("o="))
			elif line.begins_with("t="):
				song.tempos.append(Tempo.new(0.0, float(line.trim_prefix("t="))))

		elif line.begins_with("0") or line.begins_with("1") or line.begins_with("2"):
			measures[-1].append(line.left(4))

	for measure_index in len(measures):
		var measure := measures[measure_index]

		for line_index in len(measure):
			var line := measure[line_index]
			var beat := (measure_index + line_index / float(len(measure))) * 4.0

			for lane_index in len(line):
				var lane := line[lane_index]

				if lane == "1":
					chart.notes.append(Note.new(0, lane_index, beat))
				elif lane == "2" and hold_notes[lane_index] == null:
					hold_notes[lane_index] = Note.new(0, lane_index, beat)
					chart.notes.append(hold_notes[lane_index])
				elif lane == "0" and hold_notes[lane_index] != null:
					hold_notes[lane_index].length = beat - hold_notes[lane_index].beat
					hold_notes[lane_index] = null

	song.charts.append(chart)
	return song
