extends Node3D
class_name SprintRace

var race_started := false
var best_ghost : GhostPlayer = null

var ghost: GhostPlayer

@export var checkpoints : Array[Vector3]
var cp_instance : Area3D # checkpoint beam reference
var cp_idx : int # index of checkpoint
var start_cp : Area3D

@export var gold_ghost: GhostPlayer = null
@export var silver_ghost: GhostPlayer = null
@export var bronze_ghost: GhostPlayer = null

#### Data
func get_pb() -> float:
	if best_ghost == null: return 0
	return best_ghost.total_time

func get_length() -> float:
	var total := 0.0
	
	var prev = checkpoints[0]
	for pos in checkpoints:
		total += (pos - prev).length()
		prev = pos
	
	return total

#### Race management
# Starts recording and replay if available
func start_ghost() -> void:
	ghost = GhostPlayer.new()
	add_child(ghost)
	ghost.start_recording()
	
	# if medal ghosts are available
	if bronze_ghost != null:
		if get_pb() > bronze_ghost.total_time or get_pb() == 0:
			print("replaying bronze ghost")
			bronze_ghost.start_replay(Color.SANDY_BROWN)
		elif get_pb() > silver_ghost.total_time:
			print("replaying silver ghost")
			silver_ghost.start_replay(Color.SILVER)
		elif get_pb() > gold_ghost.total_time:
			print("replaying gold ghost")
			gold_ghost.start_replay(Color.GOLDENROD)
		else:
			best_ghost.start_replay()
	elif best_ghost != null:
		best_ghost.start_replay()
	else:
		print("No ghost replays available")

func start_race() -> void:
	if race_started: return
	global.player_is_racing = true
	global.sprint_node = self
	race_started = true
	cp_idx = 0
	
	start_cp.visible = false
	start_cp.monitoring = false
	global.ui_manager.get_node("Sprint").visible = false
	global.ui_manager.timer.start()
	
	global.player_car.global_position = start_cp.global_position + Vector3(0, 0.25, 0)
	global.player_car.linear_velocity = Vector3.ZERO
	
	next_checkpoint()
	
	# Face toward first checkpoint
	global.player_car.look_at(cp_instance.global_position)
	global.player_car.rotation.y += PI/2
	
	start_ghost()

func next_checkpoint() -> void:
	cp_idx += 1
	
	if cp_instance: cp_instance.queue_free()
	
	if len(checkpoints) == cp_idx:
		finish_race()
		return
	
	global.ui_manager.timer.update_checkpoint()
	
	if cp_idx > 1:
		if best_ghost != null:
			global.ui_manager.timer.signal_checkpoint(best_ghost.cp_times[cp_idx-2])
		ghost.cp_times.append(global.ui_manager.timer.time_passed)
	
	cp_instance = load("res://Scenes/sprint/checkpoint.tscn").instantiate()
	add_child(cp_instance)
	cp_instance.global_position = checkpoints[cp_idx]

func finish_race() -> void:
	race_started = false
	global.player_is_racing = false
	global.sprint_node = null
	ghost.recording = false
	global.ui_manager.timer.stop()
	
	start_cp.visible = true
	start_cp.monitoring = true
	
	# save ghost if best
	print("sprint time: ", ghost.total_time)
	if best_ghost != null: print("best ghost time: ", best_ghost.total_time)
	if best_ghost == null or ghost.total_time < best_ghost.total_time:
		best_ghost = ghost

func _ready() -> void:
	for i in get_children():
		if i is not Node3D: continue
		checkpoints.append(i.global_position)
	
	start_cp = load("res://Scenes/sprint/start_area.tscn").instantiate()
	add_child(start_cp)
	start_cp.get_node("Name").text = name
	start_cp.global_position = checkpoints[0]
	start_cp.body_entered.connect(_on_area_3d_body_entered)
	start_cp.body_exited.connect(_on_area_3d_body_exited)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body != global.player_car: return
	
	global.ui_manager.sprint_ui.popup(self)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body != global.player_car: return
	
	global.ui_manager.chosen_sprint = null
	global.ui_manager.get_node("Sprint").visible = false
