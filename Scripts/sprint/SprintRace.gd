extends Node3D
class_name SprintRace

var race_started := false
var best_ghost : GhostPlayer = null

var ghost : GhostPlayer

@export var checkpoints : Array[Vector3]
var cp_instance : Area3D # temporary checkpoint beam reference
var cp_idx : int # index of checkpoint
var start_cp : Area3D

func init_checkpoints() -> void:
	for i in get_children():
		checkpoints.append(i.global_position)

func start_race() -> void:
	if race_started: return
	race_started = true
	cp_idx = 0
	
	start_cp.visible = false
	start_cp.monitoring = false
	global.ui_manager.hide_sprint_prompt()
	global.ui_manager.start_timer()
	
	global.player_car.global_position = start_cp.global_position
	global.player_car.linear_velocity = Vector3.ZERO
	
	next_checkpoint()
	
	# Face toward first checkpoint
	global.player_car.look_at(cp_instance.global_position)
	global.player_car.rotation.y += PI/2
	
	# startup ghost recording, replay if exists
	ghost = GhostPlayer.new()
	add_child(ghost)
	ghost.start_recording()
	
	if best_ghost != null: best_ghost.start_replay()

func next_checkpoint() -> void:
	cp_idx += 1
	
	if cp_instance: cp_instance.queue_free()
	
	if len(checkpoints) == cp_idx:
		finish_race()
		return
	
	cp_instance = load("res://Scenes/sprint/checkpoint.tscn").instantiate()
	add_child(cp_instance)
	cp_instance.global_position = checkpoints[cp_idx]

func finish_race() -> void:
	print("finished race")
	race_started = false
	ghost.recording = false
	global.ui_manager.stop_timer()
	
	start_cp.visible = true
	start_cp.monitoring = true
	
	# save ghost if best
	if best_ghost == null or ghost.total_time < best_ghost.total_time: best_ghost = ghost
	ghost = null

func _ready() -> void:
	init_checkpoints()
	
	start_cp = load("res://Scenes/sprint/start_area.tscn").instantiate()
	add_child(start_cp)
	start_cp.global_position = checkpoints[0]
	start_cp.body_entered.connect(_on_area_3d_body_entered)
	start_cp.body_exited.connect(_on_area_3d_body_exited)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body != global.player_car: return
	
	global.ui_manager.show_sprint_prompt(self)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body != global.player_car: return
	
	global.ui_manager.hide_sprint_prompt()
