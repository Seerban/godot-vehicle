extends Node3D
class_name SprintRace

var radius : float = 0.5
@export var car : Vehicle
var global_ui : GlobalUI
var race_started := false

@export var start_pos : Node3D
@export var checkpoints : Array[Node3D]
var cp_instance : Node3D # temporary checkpoint beam reference
var cp_idx : int # index of checkpoint

func _ready() -> void:
	global_ui = get_tree().get_first_node_in_group("ui")

func start_race() -> void:
	if race_started: return
	race_started = true
	cp_idx = -1
	
	global_ui.hide_sprint_prompt()
	$Area3D.visible = false
	
	car = get_tree().get_first_node_in_group("car")
	car.global_position = global_position
	car.linear_velocity = Vector3.ZERO
	next_checkpoint()
	# Face toward first checkpoint
	car.look_at(cp_instance.global_position)
	car.rotation.y += PI/2

func next_checkpoint() -> void:
	cp_idx += 1
	
	if cp_instance: cp_instance.queue_free()
	
	if len(checkpoints) == cp_idx:
		finish_race()
		return
	
	cp_instance = load("res://Scenes/sprint/checkpoint.tscn").instantiate()
	add_child(cp_instance)
	cp_instance.global_position = checkpoints[cp_idx].global_position

func finish_race() -> void:
	race_started = false
	$Area3D.visible = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body != get_tree().get_first_node_in_group("car"): return
	
	global_ui.show_sprint_prompt(self)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body != get_tree().get_first_node_in_group("car"): return
	
	global_ui.hide_sprint_prompt()
