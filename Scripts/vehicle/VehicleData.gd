extends Resource
class_name VehicleData

@export var model := "car"
@export var color := Color.WHITE
@export var material := "Gloss"

################################
# Components
@export var engine := preload("res://Resources/Engines/1_engine_stock.tres")
@export var transmission := preload("res://Resources/Transmissions/0_stock_transmission.tres")
@export var aspiration := preload("res://Resources/Aspirations/NA.tres")
@export var chassis := preload("res://Resources/Chassis/default_chassis.tres")
@export var weight_kit := preload("res://Resources/WeightKits/0_no_weight_kit.tres")
@export var aero_kit := preload("res://Resources/AeroKits/0_no_aero.tres")
@export var suspension := preload("res://Resources/Suspensions/0_default_suspension.tres")
@export var tires := preload("res://Resources/Tires/0_default_tires.tres")
@export var brakes := preload("res://Resources/Brakes/0_stock_brakes.tres")
@export var drivetrain := preload("res://Resources/Drivetrains/1_RWD.tres")

################################
# tuning variables
@export var brake_bias := 0.0 # rear-front force split (-1 = 100% rear,  1 = 100% front)
@export var aero_bias := 0.0
@export var turning_deg := 20.0

func add_as_vehicle(target : Node) -> Vehicle:
	var vehicle: Vehicle = load(global.CAR_MODEL_PATH + model + ".tscn").instantiate()
	target.add_child(vehicle)
	vehicle.update_color(color, material)
	
	vehicle.engine = engine
	vehicle.transmission = transmission
	vehicle.aspiration = aspiration
	vehicle.chassis = chassis
	vehicle.weight_kit = weight_kit
	vehicle.aero_kit = aero_kit
	vehicle.suspension = suspension
	vehicle.tires = tires
	vehicle.brakes = brakes
	vehicle.drivetrain = drivetrain
	
	vehicle.brake_bias = brake_bias
	vehicle.aero_bias = aero_bias
	
	vehicle.turning_deg = turning_deg
	
	return vehicle
