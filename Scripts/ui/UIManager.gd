extends CanvasLayer
class_name UIManager

var in_sprint_radius := false
var chosen_sprint : Node3D

@onready var meters = $Meters
@onready var sprint_ui = $Sprint
@onready var timer := $Timer

func show_unique_children(child_name: Array[String]) -> void:
	for i in get_children():
		i.visible = i.name in child_name

func show_usual() -> void:
	show_unique_children(["Meters", "LeftMenu"])

func update_sprint(sprint : Node3D = null) -> void:
	chosen_sprint = sprint
	return
