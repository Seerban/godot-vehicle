extends CanvasLayer
class_name UIManager

var airtime := 0.0
var drifttime := 0.0
const drift_loss_cooldown := 3.0
var drift_loss_time_left := 0.0
var speedtime := 0.0

var in_sprint_radius := false
var chosen_sprint : Node3D

@onready var meters = $Meters
@onready var sprint_ui = $Sprint
@onready var sprint_live_ui := $SprintLive
@onready var sprint_finish_ui := $SprintFinish
@onready var autoshop_ui := $Autoshop
@onready var autoshop_popup := $AutoshopPopup
@onready var score := $LeftMenu/HBox/ScorePopup
@onready var airtime_label = score.get_node("Airtime")
@onready var drift_label = score.get_node("Drift")
@onready var speed_label = score.get_node("Speed")

func _ready() -> void:
	for i in get_children():
		if i.has_method("update_player_data"):
				i.update_player_data()

func _physics_process(delta: float) -> void:
	if global.player_car != null:
		update_airtime(delta)
		update_drifttime(delta)
		update_speedtime(delta)
	else: airtime = 0

# main function for switching UIs
func show_unique_children(child_name: Array[String]) -> void:
	for i in get_children():
		if i.name in child_name:
			i.visible = true
			if i.has_method("update_player_data"):
				i.update_player_data()
		else:
			i.visible = false

func show_usual() -> void:
	if !global.player_is_racing:
		show_unique_children(["Meters", "LeftMenu"])
	else:
		show_unique_children(["Meters", "LeftMenu", "SprintLive"])

func update_sprint(sprint : Node3D = null) -> void:
	chosen_sprint = sprint
	return

func update_airtime(delta: float) -> void:
	if !global.player_car.is_grounded:
		airtime += delta
	else: airtime = 0
	
	if airtime > 1.0:
		airtime_label.visible = true
		airtime_label.modulate = Color.WHITE
		airtime_label.text = "Airtime: %.1f" % airtime
	else:
		airtime_label.modulate = lerp(airtime_label.modulate, Color.TRANSPARENT, 0.05)
	
	if airtime_label.modulate.a < 0.1:
		airtime_label.visible = false

func update_drifttime(delta: float) -> void:
	if global.player_car.is_drifting:
		drifttime += delta
		drift_loss_time_left = drift_loss_cooldown
	else:
		drift_loss_time_left -= delta
		if drift_loss_time_left <= 0.0: drifttime = 0
	
	if drifttime > 1.0:
		drift_label.visible = true
		drift_label.modulate = Color.WHITE
		drift_label.text = "Drifttime: %.1f" % drifttime
	else:
		drift_label.modulate = lerp(drift_label.modulate, Color.TRANSPARENT, 0.05)
	
	if drift_label.modulate.a < 0.1:
		drift_label.visible = false

func update_speedtime(delta: float) -> void:
	if global.player_car.is_speeding:
		speedtime += delta
	else: speedtime = 0
	
	if speedtime > 1.0:
		speed_label.visible = true
		speed_label.modulate = Color.WHITE
		speed_label.text = "Speedtime: %.1f" % speedtime
	else:
		speed_label.modulate = lerp(speed_label.modulate, Color.TRANSPARENT, 0.05)
	
	if speed_label.modulate.a < 0.1:
		speed_label.visible = false
