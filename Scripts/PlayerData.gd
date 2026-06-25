extends Resource
class_name PlayerData

@export var user := "User"
@export var cash := 100.0
@export var vehicle := VehicleData.new()

@export var times: Dictionary[String,GhostData]
@export var races_completed := 0

@export var distance_traveled := 0.0
@export var jump_time := 0.0
@export var drift_time := 0.0
@export var speed_time := 0.0

@export var trophies := 0

func get_medal_count(races_parent: Node3D) -> int:
	var total = 0
	for i in races_parent.get_children():
		total += i.get_medal()
	return total
