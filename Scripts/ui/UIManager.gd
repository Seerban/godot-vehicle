extends CanvasLayer
class_name UIManager

var in_sprint_radius := false
var chosen_sprint : Node3D

@onready var meters = $Meters
@onready var sprint_ui = $Sprint
@onready var sprint_live_ui := $SprintLive
@onready var sprint_finish_ui := $SprintFinish

func show_unique_children(child_name: Array[String]) -> void:
	for i in get_children():
		i.visible = i.name in child_name

func show_usual() -> void:
	if !global.player_is_racing:
		show_unique_children(["Meters", "LeftMenu"])
	else:
		show_unique_children(["Meters", "LeftMenu", "SprintLive"])

func update_sprint(sprint : Node3D = null) -> void:
	chosen_sprint = sprint
	return
