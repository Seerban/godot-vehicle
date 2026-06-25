extends Control

# Ticker on progress bar with trophy display
@onready var progress_ticker = $Scroll/VBox/Distance/DistanceProgress/Ticker.duplicate()

var max_trophies

func _ready() -> void:
	# only used as a model for instancing copies
	$Scroll/VBox/Distance/DistanceProgress/Ticker.queue_free()

# update call on visibility change
func update() -> void:
	update_bar($Scroll/VBox/Distance/DistanceProgress, [10000.0, 25000.0, 50000.0, 100000.0], global.player_data.distance_traveled)
	update_bar($Scroll/VBox/Medals/MedalsProgress, [3.0, 6.0, 10.0, 15.0], \
		global.player_data.get_medal_count(get_tree().get_first_node_in_group("map").get_node("Races")))
	update_bar($Scroll/VBox/Races/RacesProgress, [5.0, 15.0, 30.0, 100.0], global.player_data.races_completed)
	update_bar($Scroll/VBox/Drift/DriftProgress, [25.0, 50.0, 100.0, 300.0], global.player_data.drift_time)
	update_bar($Scroll/VBox/Speed/SpeedProgress, [25.0, 50.0, 100.0, 300.0], global.player_data.speed_time)
	update_bar($Scroll/VBox/Air/AirProgress, [25.0, 50.0, 100.0, 300.0], global.player_data.jump_time)

# add progress tickers and add trophies if reached by comparison value
func update_bar(bar_ref: ProgressBar, values: Array, compare_value: int) -> void:
	var max_val = values[ len(values) - 1 ]
	
	for i in bar_ref.get_children():
		if i is ColorRect:
			i.queue_free()
	
	bar_ref.max_value = max_val
	bar_ref.value = compare_value
	bar_ref.get_node("Label").text = str(compare_value)
	
	for i in values:
		var t: ColorRect = progress_ticker.duplicate()
		t.get_node("Label").text = str(int(i))
		t.anchor_left = i / max_val
		t.anchor_right = i / max_val
		t.get_node("Trophy").modulate = Color(1, 1, 1, 0.5)
		
		if compare_value >= i:
			t.get_node("Trophy").modulate = Color(1, 1, 1, 1)
			t.color = Color.GREEN_YELLOW
		
		bar_ref.add_child(t)
		bar_ref.move_child(t, 0)
