extends Control

func _ready() -> void:
	$ColorRect/Cash.text = "$" + str(int(global.player_data.cash))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_exit_button_pressed()

func _on_exit_button_pressed() -> void:
	visible = false

func purchase(model: String, price: float) -> void:
	global.player_data.cash -= price
	global.player_car.components = VehicleData.new()
	global.player_car.components.model = model
	
	visible = false
	get_parent()._on_back_pressed() 

func _on_oddi_buy_mouse_entered() -> void:
	$HBox/Oddi/Name.self_modulate = Color.CORNFLOWER_BLUE

func _on_oddi_buy_mouse_exited() -> void:
	$HBox/Oddi/Name.self_modulate = Color.WHITE

func _on_oddi_buy_pressed() -> void:
	purchase("Oddi", 7500)

func _on_mousse_buy_mouse_entered() -> void:
	$HBox/Mousse/Name.self_modulate = Color.CORNFLOWER_BLUE

func _on_mousse_buy_mouse_exited() -> void:
	$HBox/Mousse/Name.self_modulate = Color.WHITE

func _on_mousse_buy_pressed() -> void:
	purchase("Mousse", 8500)


func _on_lando_buy_mouse_entered() -> void:
	$HBox/Lando/Name.self_modulate = Color.CORNFLOWER_BLUE

func _on_lando_buy_mouse_exited() -> void:
	$HBox/Lando/Name.self_modulate = Color.WHITE

func _on_lando_buy_pressed() -> void:
	purchase("Lando", 25000)
