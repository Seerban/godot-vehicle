extends ColorRect

@onready var car
var bars : Array[ProgressBar]

func update_ui() -> void:
	for bar in bars: bar.queue_free()
	bars.clear()
	
	for i in range( len(car.wheels) ):
		var wheel = car.wheels[i]
		var bar : ProgressBar = load("res://UI/grip_bar.tscn").instantiate()
		bar.position.x = wheel.position.z * 32 - 16
		bar.position.y = wheel.position.x * -32 - 16
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
		bars[i].value = car.wheels[i].get_used_grip() / car.wheels[i].get_grip() * 100
		bars[i].get_node("Label").text = str( int( car.wheels[i].get_used_grip() * 10) )
