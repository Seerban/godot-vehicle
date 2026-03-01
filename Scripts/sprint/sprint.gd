extends Node3D
class_name SprintRace

var race_started := false
var radius : float = 0.5
var best_ghost : GhostPlayer = null

var car : Vehicle
var ghost : GhostPlayer
var global_ui : GlobalUI

@export var start_pos : Node3D
@export var checkpoints : Array[Vector3]
var cp_instance : Node3D # temporary checkpoint beam reference
var cp_idx : int # index of checkpoint

func init_checkpoints() -> void:
	for i in get_children():
		checkpoints.append(i.global_position)

func start_race() -> void:
	if race_started: return
	race_started = true
	cp_idx = 0
	
	global_ui.hide_sprint_prompt()
	global_ui.start_timer()
	$Area3D.visible = false
	
	car = get_tree().get_first_node_in_group("car")
	car.global_position = global_position + Vector3(0, 0.5, 0)
	car.linear_velocity = Vector3.ZERO
	
	next_checkpoint()
	
	# Face toward first checkpoint
	car.look_at(cp_instance.global_position)
	car.rotation.y += PI/2
	
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
	global_ui.stop_timer()
	$Area3D.visible = true
	
	# save ghost if best
	if best_ghost == null or ghost.total_time < best_ghost.total_time: best_ghost = ghost
	ghost = null

func _ready() -> void:
	global_ui = get_tree().get_first_node_in_group("ui")
	car = get_tree().get_first_node_in_group("car")
	init_checkpoints()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body != get_tree().get_first_node_in_group("car"): return
	
	global_ui.show_sprint_prompt(self)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body != get_tree().get_first_node_in_group("car"): return
	
	global_ui.hide_sprint_prompt()
