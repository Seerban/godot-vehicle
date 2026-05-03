extends Control

var time_passed := 0.0
var cp_idx := 0
@onready var timer = $Timer

var exit_progress := 0.0
@onready var exit_bar := $Exit/Bar

func start():
	visible = true
	time_passed = 0.0
	cp_idx = 0
	set_process(true)

func stop():
	visible = false
	set_process(false)

func update_checkpoint() -> void:
	cp_idx += 1
	if global.sprint_node == null:
		$CP.text = ""
		return
	$CP.text = "CP: %s/%s" % [str(cp_idx), str(len(global.sprint_node.checkpoints))]
 
func signal_checkpoint(time_to_beat : float):
	$TimeDiff.visible = true
	$TimeDiff/Time.text = global.format_time( time_passed )
	var time_diff = time_to_beat - time_passed
	$TimeDiff/Diff.text = global.format_time( abs(time_diff) )
	if time_diff < 0: $TimeDiff/Diff.modulate = Color.RED
	else: $TimeDiff/Diff.modulate = Color.BLUE
	
	await global.wait(2.0)
	
	$TimeDiff.visible = false

func signal_end_race():
	global.force_end_race()

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if !visible: set_process(false)
	
	time_passed += delta
	timer.text = global.format_time(time_passed)
	
	exit_progress = move_toward(exit_progress, int(Input.is_key_pressed(KEY_Q)), delta)
	exit_bar.value = exit_progress
	
	if exit_bar.value == 1.0:
		signal_end_race()

func _on_visibility_changed() -> void:
	set_process(true)
