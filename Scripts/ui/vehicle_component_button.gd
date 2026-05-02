extends Button

@export var res : VehicleComponent
@export var initializer_ref : Control

func _ready() -> void:
	text = res.name

func _on_pressed() -> void:
	var car = global.player_car
	if res is EngineStats: 			car.components.engine = res
	if res is TransmissionStats: 	car.components.transmission = res
	if res is WeightKitStats:		car.components.weight_kit = res
	if res is DrivetrainStats:		car.components.drivetrain = res
	if res is BrakesStats:			car.components.brakes = res
	if res is AeroKitStats:			car.components.aero_kit = res
	if res is TiresStats:			car.components.tires = res
	if res is SuspensionStats:		car.components.suspension = res
	if res is AspirationStats:		car.components.aspiration = res
	
	initializer_ref.update()
