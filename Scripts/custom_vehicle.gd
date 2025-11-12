extends RigidBody3D
class_name Vehicle

@export var power := 4.25
@export var brake_power := 2
@export var turning_deg := 18.

var wheels : Array[Wheel]

func _ready() -> void:
	for i in get_children():
		if i is Wheel:
			wheels.append(i)

func _physics_process(delta: float) -> void:
	#angular_velocity *= 0.99
	
	if Input.is_action_pressed("forward"):
		for w in wheels:
			w.accelerate(power)
	if Input.is_action_pressed("backward"):
		for w in wheels:
			w.brake(brake_power)
	var steering = Input.get_axis("right","left")
	for w in wheels:
		w.steer(steering * turning_deg)
