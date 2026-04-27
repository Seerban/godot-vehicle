extends Resource
class_name PlayerData

@export var user := "User"
@export var cash := 100.0
@export var vehicle := VehicleData.new()
@export var times: Dictionary[String,GhostData]
