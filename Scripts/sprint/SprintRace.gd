@tool
extends Node3D
class_name SprintRace

# Base reward multiplied by medal multiplier
@export var base_reward := 100.0

var race_started := false
var ghost: GhostPlayer # current tracking gohst
var best_ghost := GhostPlayer.new() # for replays

# checkpoints initialized by node3d children
var checkpoints : Array[Vector3]
# reference to checkpoint scene instance
var cp_instance : Area3D
# tracker for which checkpoint is active
var cp_idx : int
var start_cp : Area3D

# inserted in editor
@export var gold_data: GhostData = null
@export var silver_data: GhostData = null
@export var bronze_data: GhostData = null

# If player has no replay, return 0
func get_pb() -> float:
	if !global.player_data.times.get(name):
		return 0.0
	return global.player_data.times.get(name).total_time

# total distance (Doesn't account for road curvature"
func get_length() -> float:
	var total := 0.0
	
	var prev = checkpoints[0]
	for pos in checkpoints:
		total += (pos - prev).length()
		prev = pos
	
	return total


# create ghost and start recording
# start best medal/replay ghost available for replay
func start_ghost() -> void:
	ghost = GhostPlayer.new()
	add_child(ghost)
	ghost.start_recording()
	
	# if medal ghosts are available, start replay
	add_child(best_ghost)
	#if gold_data != null and (get_pb() != 0 and get_pb() > gold_data.total_time):
	if get_pb() != 0 and gold_data == null:
		best_ghost.data = global.player_data.times[name]
		best_ghost.start_replay(Color.WHITE)
	if get_pb() > bronze_data.total_time or get_pb() == 0:
		best_ghost.data = bronze_data
		best_ghost.start_replay(Color.SANDY_BROWN)
	elif get_pb() > silver_data.total_time:
		best_ghost.data = silver_data
		best_ghost.start_replay(Color.SILVER)
	elif get_pb() > gold_data.total_time:
		best_ghost.data = gold_data
		best_ghost.start_replay(Color.GOLDENROD)
	else:
		if get_pb() != 0:
			best_ghost.data = global.player_data.times[name]
		best_ghost.start_replay(Color.WHITE)

# start race, positions player, starts first checkpoint and UI
func start_race() -> void:
	if race_started: return
	
	await global.ui_manager.enable_black()
	
	global.player_is_racing = true
	global.sprint_node = self
	race_started = true
	cp_idx = 0
	
	start_cp.visible = false
	start_cp.monitoring = false
	global.ui_manager.show_usual() # show_usual displays additional UIs if global.player_is_racing
	global.ui_manager.sprint_live_ui.start()
	
	global.player_car.global_position = start_cp.global_position + Vector3(0, 0.25, 0)
	global.player_car.linear_velocity = Vector3.ZERO
	global.player_car.disable() # disable until fade screen ends
	
	# initialize checkpoint
	next_checkpoint()
	
	# Face toward first checkpoint and update camera
	global.player_car.look_at(cp_instance.global_position)
	global.player_car.rotation.y += PI/2
	global.camera.reset()
	
	await global.ui_manager.disable_black()
	global.player_car.enable()
	
	start_ghost()

# free current instance and spawn another at next pos
func next_checkpoint() -> void:
	cp_idx += 1
	
	if cp_instance: cp_instance.queue_free()
	
	if len(checkpoints) == cp_idx:
		finish_race()
		return
	
	global.ui_manager.sprint_live_ui.update_checkpoint()
	
	if cp_idx > 1:
		if global.player_data.times.get(name):
			global.ui_manager.sprint_live_ui.signal_checkpoint(global.player_data.times[name].cp_times[cp_idx-2])
		ghost.data.cp_times.append(global.ui_manager.sprint_live_ui.time_passed)
	
	cp_instance = load("res://Scenes/sprint/checkpoint.tscn").instantiate()
	add_child(cp_instance)
	cp_instance.global_position = checkpoints[cp_idx]
	
	# Update race statistics
	global.player_data.races_completed += 1

# give rewards and save ghost if good time and not force exited
func finish_race(forced := false) -> void:
	race_started = false
	global.player_is_racing = false
	global.sprint_node = null
	ghost.recording = false
	
	global.ui_manager.sprint_live_ui.stop()
	global.ui_manager.show_usual()
	
	start_cp.visible = true
	start_cp.monitoring = true
	
	# Don't update PB if forced exit
	if forced: 
		cp_instance.queue_free()
		return
	
	
	var cash_reward = 0
	if bronze_data != null:
		var cash_multiplier := 0.33
		if ghost.data.total_time < bronze_data.total_time: cash_multiplier = 1.0
		if ghost.data.total_time < silver_data.total_time: cash_multiplier = 2.0
		if ghost.data.total_time < silver_data.total_time: cash_multiplier = 3.0
		cash_reward = base_reward * cash_multiplier
	
	global.ui_manager.sprint_finish_ui.popup(self, ghost.data.total_time, cash_reward)
	global.player_data.cash += cash_reward
	
	# save ghost if best
	print("sprint time: ", ghost.data.total_time)
	if get_pb() == 0 or global.player_data.times[name].total_time > ghost.data.total_time:
		global.player_data.times[name] = ghost.data

# transform children to checkpoints array
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
	
	if global.player_data.times.get(name):
		best_ghost.data = global.player_data.times[name]

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body != global.player_car: return
	
	global.ui_manager.sprint_ui.popup(self)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body != global.player_car: return
	
	global.ui_manager.chosen_sprint = null
	global.ui_manager.get_node("Sprint").visible = false
