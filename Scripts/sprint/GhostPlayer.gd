extends Node
class_name GhostPlayer

var car: Vehicle
var car_mesh: MeshColorable # We track this instead of car for accurate scaling
@export var model: String
var body: MeshColorable

var recording := false
var replaying := false

@export var total_time := 0.0
var frame_rate := 0.1
var clock := 0.0

@export var frames := []
@export var cp_times := []

func start_recording() -> void:
	set_process(true)
	
	car = global.player_car
	model = car.car_model
	car_mesh = car.mesh
	
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
			"transform": car_mesh.global_transform
		})

func start_replay(label_col := Color.WHITE) -> void:
	set_process(true)
	
	body = global.get_car_model_instance(model)
	body.update_material("Ghost")
	add_child(body)
	
	var label = Label3D.new()
	body.add_child(label)
	label.text = "v"
	label.billboard = true
	label.position.y += 0.6
	label.modulate = label_col
	
	body.rotation.y += PI/2
	clock = 0.0
	replaying = true

func _replay_process(delta : float) -> void:
	if !is_instance_valid(body):
		print("ERROR: invalid ghost body to replay")
		return
	
	if clock > total_time:
		print("FINISHED REPLAY")
		remove_child(body)
		replaying = false
		return
	else:
		clock += delta
		var idx = int(clock / frame_rate) - 1
		if idx >= len(frames)-1: return
		
		var t0 = frames[idx]["time"]
		var t1 = frames[idx + 1]["time"]
		var weight = (clock - t0) / frame_rate
		
		body.global_transform = frames[idx]["transform"].interpolate_with(
			frames[idx + 1]["transform"],
			weight
		)

func stop_recording() -> void:
	body.queue_free()
	recording = false
	set_process(false)

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if recording: _record_process(delta)
	elif replaying: _replay_process(delta)
	else: set_process(false)
