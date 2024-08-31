class_name Layer

var id: int
var position: float = 0.0
var scale: float = 1.0

var _position_items: Array[_Step] = []
var _position_index: int = 0
var _scale_items: Array[_Curve] = []
var _scale_index: int = 0


func _init(id_: int):
	id = id_


func setup():
	_position_items.clear()
	_position_index = 0
	_scale_items.clear()
	_scale_index = 0

	# Gather speed curves that belong to this layer.
	var speed_curves: Array[_Curve] = []
	for speed in Game.chart.speeds:
		if speed.layer == id:
			speed_curves.append(_Curve.new(Game.timing.get_time(speed.beat), speed.value, speed.curve))

	# Convert speed curves to segments of constant speed.
	for index in range(len(speed_curves) - 1):
		var start := speed_curves[index]
		var end := speed_curves[index + 1]

		# Don't bother adding a ton of steps if the speed is constant.
		if is_equal_approx(start.curve, 0.0) or is_equal_approx(start.value, end.value):
			_position_items.append(_Step.new(start.time, start.value))
			continue

		# Using 20 steps per second should make it smooth enough.
		var duration := end.time - start.time
		var steps := maxi(ceili(duration * 20.0), 1)

		for step in range(steps):
			var weight := float(step) / float(steps)
			var time := lerpf(start.time, end.time, weight)
			var value := lerpf(start.value, end.value, ease(weight, start.curve))
			_position_items.append(_Step.new(time, value))

	if not speed_curves.is_empty():
		var last := speed_curves[-1]
		_position_items.append(_Step.new(last.time, last.value))

	# Calculate position at the start of each speed step.
	if not _position_items.is_empty():
		_position_items[0].setup()
	for index in range(1, len(_position_items)):
		_position_items[index].setup(_position_items[index - 1])

	# Gather zoom curves that belong to this layer.
	for zoom in Game.chart.zooms:
		if zoom.layer == id:
			_scale_items.append(_Curve.new(Game.timing.get_time(zoom.beat), zoom.value, zoom.curve))


func update(time: float):
	position = get_position(time)
	scale = get_scale(time)


func get_position(time: float) -> float:
	if _position_items.is_empty():
		return time

	# Find the closest segment using linear search.
	while _position_index < len(_position_items) and time > _position_items[_position_index].time:
		_position_index += 1
	while _position_index > 0 and time < _position_items[_position_index - 1].time:
		_position_index -= 1

	# Handle cases before the first segment and after the last.
	if _position_index == 0 or _position_index == len(_position_items):
		var item := _position_items[_position_index if _position_index == 0 else -1]
		return item.position + (time - item.time) * item.value

	# Interpolate to get the position at this time.
	var start := _position_items[_position_index - 1]
	var end := _position_items[_position_index]
	var weight := inverse_lerp(start.time, end.time, time)
	return lerpf(start.position, end.position, weight)


func get_scale(time: float) -> float:
	if _scale_items.is_empty():
		return 1.0

	# Find the closest segment using linear search.
	while _scale_index < len(_scale_items) and time > _scale_items[_scale_index].time:
		_scale_index += 1
	while _scale_index > 0 and time < _scale_items[_scale_index - 1].time:
		_scale_index -= 1

	# Handle cases before the first segment and after the last.
	if _scale_index == 0 or _scale_index == len(_scale_items):
		var item := _scale_items[0 if _scale_index == 0 else -1]
		return item.value

	# Interpolate to get the scale at this time.
	var start := _scale_items[_scale_index - 1]
	var end := _scale_items[_scale_index]
	var weight := inverse_lerp(start.time, end.time, time)
	return lerpf(start.value, end.value, ease(weight, start.curve))


class _Curve:
	var time: float
	var value: float
	var curve: float

	func _init(time_: float, value_: float, curve_: float):
		time = time_
		value = value_
		curve = curve_


class _Step:
	var time: float
	var value: float

	var position: float

	func _init(time_: float, value_: float):
		time = time_
		value = value_

	func setup(prev: _Step = null):
		if prev:
			position = prev.position + (time - prev.time) * prev.value
		else:
			position = time * value
