extends Node3D

const right_offset := 2.5

@export var target_path: Path3D
@export var move_speed: float = 15.0
@export var reversed: bool = false

var progress: float = 0.0

func _physics_process(delta: float) -> void:
	if target_path == null:
		return
	
	move_along_path(delta)

func move_along_path(delta: float) -> void:
	var curve := target_path.curve
	if curve == null:
		return
	
	var path_length := curve.get_baked_length()

	if reversed:
		progress -= move_speed * delta
	else:
		progress += move_speed * delta

	progress = wrapf(progress, 0.0, path_length)

	var current_pos := curve.sample_baked(progress)

	var look_distance := 0.5
	var sample_progress := progress + look_distance
	
	if reversed:
		sample_progress = progress - look_distance

	sample_progress = wrapf(sample_progress, 0.0, path_length)

	var sample_pos := curve.sample_baked(sample_progress)

	var forward := (sample_pos - current_pos).normalized()

	var right := forward.cross(Vector3.UP).normalized()

	var offset := right * right_offset

	global_position = current_pos + offset
