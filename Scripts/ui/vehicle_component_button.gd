extends Button

@export var res : VehicleComponent
@export var initializer_ref : Control

func _ready() -> void:
	text = res.name

func _on_pressed() -> void:
	var car = global.player_car
	if res is EngineStats: 			car.engine = res
	if res is TransmissionStats: 	car.transmission = res
	if res is WeightKitStats:		car.weight_kit = res
	if res is DrivetrainStats:		car.drivetrain = res
	if res is BrakesStats:			car.brakes = res
	if res is AeroKitStats:			car.aero_kit = res
	if res is TiresStats:			car.tires = res
	if res is SuspensionStats:		car.suspension = res
	if res is AspirationStats:		car.aspiration = res
	
	initializer_ref.update()
