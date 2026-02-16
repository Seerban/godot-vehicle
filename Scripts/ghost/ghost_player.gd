extends Node
class_name GhostPlayer

var car : Vehicle # car to track
var ghost_car : RigidBody3D = null
var recording := false
var replaying := false
var total_time := 0.0
var frame_rate := 0.2 # How often to screenshot car position
var clock := 0.0

var transforms : Array[Transform3D]

func start_recording() -> void:
	car = get_tree().get_first_node_in_group("car")
	recording = true
	transforms = []

func _record_process(delta : float) -> void:
	if clock >= frame_rate:
		clock = 0.0
		transforms.append( car.global_transform )
	else:
		clock += delta
	total_time += delta

func start_replay() -> void:
	clock = 0.0
	replaying = true
	ghost_car = load("res://Scenes/vehicle/ghost_body.tscn").instantiate()
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
		if idx >= len(transforms)-1: return
		var weight = (clock - idx * frame_rate) / frame_rate
		
		ghost_car.global_transform = transforms[ idx ].interpolate_with(transforms[idx+1], weight)

func stop_recording() -> void:
	recording = false

func _process(delta: float) -> void:
	if recording: _record_process(delta)
	elif replaying: _replay_process(delta)
