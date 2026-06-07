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
@export var speed_time = 0.0
