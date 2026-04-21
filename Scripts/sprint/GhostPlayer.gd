extends Node
class_name GhostPlayer

var car : Vehicle # car to track
var ghost_car : RigidBody3D = null

var recording := false
var replaying := false

var total_time := 0.0
var frame_rate := 0.1
var clock := 0.0

var frames := []
var cp_times := []

func start_recording() -> void:
	car = global.player_car
	recording = true
	frames = []
	total_time = 0.0
	clock = 0.0

func _record_process(delta: float) -> void:
	clock += delta
	total_time += delta
	
	while clock >= frame_rate:
		clock -= frame_rate
		frames.append({
			"time": total_time,
			"transform": car.global_transform
		})

func start_replay() -> void:
	clock = 0.0
	replaying = true
	ghost_car = load("res://Scenes/sprint/ghost_body.tscn").instantiate()
	add_child(ghost_car)

func _replay_process(delta : float) -> void:
	if clock > total_time:
		print("FINISHED REPLAY")
		ghost_car.queue_free()
		replaying = false
		return
	else:
		clock += delta
		var idx = int(clock / frame_rate)
		if idx >= len(frames)-1: return
		
		var t0 = frames[idx]["time"]
		var t1 = frames[idx + 1]["time"]
		var weight = (clock - t0) / (t1 - t0)
		
		ghost_car.global_transform = frames[idx]["transform"].interpolate_with(
			frames[idx + 1]["transform"],
			weight
		)

func stop_recording() -> void:
	recording = false

func _process(delta: float) -> void:
	if recording: _record_process(delta)
	elif replaying: _replay_process(delta)
