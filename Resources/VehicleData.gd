extends Resource
class_name VehicleData

var attached_body: Node3D

@export var model := "car" :
	set(x):
		model = x
		if attached_body != null: attached_body.update()
@export var color := Color.WHITE :
	set(x):
		color = x
		if attached_body != null: attached_body.update()
@export var material := "Gloss" :
	set(x):
		material = x
		if attached_body != null: attached_body.update()

################################
# stats computed from components
var weight := 1.0
var drag := 1.0
var downforce := 1.0
var top_speed := 1.0
var power := 1.0
var boost := 1.0
var brake_power := 1.0
var height := 1.0

################################
# Components
@export var engine := preload("res://Resources/Engines/1_engine_stock.tres") :
	set(x):
		engine = x
		if attached_body != null: attached_body.update()
@export var transmission := preload("res://Resources/Transmissions/0_stock_transmission.tres") :
	set(x):
		transmission = x
		if attached_body != null: attached_body.update()
@export var aspiration := preload("res://Resources/Aspirations/NA.tres") :
	set(x):
		aspiration = x
		if attached_body != null: attached_body.update()
@export var chassis := preload("res://Resources/Chassis/car_chassis.tres") :
	set(x):
		chassis = x
		if attached_body != null: attached_body.update()
@export var weight_kit := preload("res://Resources/WeightKits/0_no_weight_kit.tres") :
	set(x):
		weight_kit = x
		if attached_body != null: attached_body.update()
@export var aero_kit := preload("res://Resources/AeroKits/0_no_aero.tres") :
	set(x):
		aero_kit = x
		if attached_body != null: attached_body.update()
@export var suspension := preload("res://Resources/Suspensions/0_default_suspension.tres") :
	set(x):
		suspension = x
		if attached_body != null: attached_body.update()
@export var tires := preload("res://Resources/Tires/0_default_tires.tres") :
	set(x):
		tires = x
		if attached_body != null: attached_body.update()
@export var brakes := preload("res://Resources/Brakes/0_stock_brakes.tres") :
	set(x):
		brakes = x
		if attached_body != null: attached_body.update()
@export var drivetrain := preload("res://Resources/Drivetrains/1_RWD.tres") :
	set(x):
		drivetrain = x
		if attached_body != null: attached_body.update()

@export var turning_deg := 20.0

func _init() -> void:
	print("initialized vehicledata of model " + model)
	chassis = load("res://Resources/Chassis/%s_chassis.tres" % model)

func get_weight() -> float: return weight
func get_drag() -> float: return drag
func get_downforce() -> float: return downforce
func get_top_speed() -> float: return top_speed
func get_power() -> float: return power
func get_boost() -> float: return boost
func get_brake_power() -> float: return brake_power
func get_height() -> float: return height

func update():
	weight = chassis.weight * weight_kit.weight_multiplier + engine.weight + transmission.weight + aspiration.weight \
		+ aero_kit.weight + suspension.weight + tires.weight + brakes.weight + drivetrain.weight
	drag = chassis.drag + aero_kit.drag
	downforce = chassis.downforce + aero_kit.downforce
	top_speed = engine.speed * transmission.multiplier * (1 + transmission.long_bias)
	power = engine.power * transmission.multiplier * (1 - transmission.long_bias)
	boost = aspiration.power_multiplier
	brake_power = brakes.brake_power
	height = suspension.get_length()

func add_as_vehicle(target : Node, low_detail = false) -> Vehicle:
	var vehicle: Vehicle = load(global.CAR_MODEL_PATH + model + ".tscn").instantiate()
	if low_detail:
		vehicle.set_script( load("res://Scripts/vehicle/LDVehicle.gd") )
	
	target.add_child(vehicle)
	vehicle.components = self # auto calls update on vehicle
	
	return vehicle
