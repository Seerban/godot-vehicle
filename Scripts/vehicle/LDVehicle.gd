class_name LDVehicle
extends Vehicle

# simplified model of vehicle for non player cars, for full version see Vehicle.gd

func _ready() -> void:
	components.attached_body = self
	mesh = $CarMesh
	center_of_mass.y = components.chassis.CoM_Y
	
	if controller is PlayerController: global.player_car = self
	controller.vehicle = self
	
	for axle in get_children():
		if axle is VehicleAxle: axle.use_ldwheel = true
	
	update()

func _physics_process(delta : float) -> void:
	if !enabled: return
	
	controller.custom_process(delta)
	set_acceleration( controller.accel_handler(delta) )
	set_braking( controller.brake_handler(delta) )
	set_steering( controller.steer_handler(delta) )
	_aero()

func set_acceleration(x := 0.) -> void:
	for axle in axles:
		for w in wheels:
			w.accel_power = x * get_power_output()

func set_braking(x := 0.) -> void:
	for axle in axles:
		for w in wheels:
			w.brake_power = x * components.get_brake_power()
			w.brake_power *= components.get_brake_power()
