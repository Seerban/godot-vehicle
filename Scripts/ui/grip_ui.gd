extends ColorRect

@onready var car
var bars : Array[ProgressBar]

func update_ui() -> void:
	for bar in bars: bar.queue_free()
	bars.clear()
	
	for axle in car.axles:
		for wheel in axle.get_children():
			var bar : ProgressBar = load("res://UI/grip_bar.tscn").instantiate()
			
			bar.position.x = (axle.position.z + wheel.position.z) * 32 - 16
			bar.position.y = (axle.position.x + wheel.position.x) * -32 - 16
			
			add_child(bar)
			bars.append(bar)

func _ready() -> void:
	car = get_tree().get_first_node_in_group("car")
	update_ui()

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if not car:
		car = global.player_car
	
	for i in range( len(bars) ):
		var used_grip = car.wheels[i].get_used_lat_grip() + car.wheels[i].get_used_long_grip()
		var max_grip = car.wheels[i].get_lat_grip() + car.wheels[i].get_long_grip()
		bars[i].value = used_grip / max_grip * 100
		bars[i].get_node("Label").text = str( int( used_grip * 10) )
