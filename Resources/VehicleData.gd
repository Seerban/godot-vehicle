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
@export var chassis := preload("res://Resources/Chassis/default_chassis.tres") :
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

func add_as_vehicle(target : Node) -> Vehicle:
	var vehicle: Vehicle = load(global.CAR_MODEL_PATH + model + ".tscn").instantiate()
	target.add_child(vehicle)
	vehicle.components = self
	
	return vehicle
