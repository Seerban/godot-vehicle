extends Panel

const chosen_scale := 0.5

var paths : Array[RoadPath]
var water_bodies : Array[Path3D]

@onready var static_map := $StaticMap
@onready var dynamic_map := $DynamicMap
@onready var map
var terrain: Terrain3D

func update_offset(pos : Vector2) -> void:
	static_map.position = pos * chosen_scale + get_rect().size / 2.0 - static_map.get_rect().size / 2.0
	dynamic_map.position = pos * chosen_scale + get_rect().size / 2.0 - dynamic_map.get_rect().size / 2.0

func _ready() -> void:
	map = get_tree().get_first_node_in_group("map")
	terrain = map.get_node("Terrain")
	
	static_map.scale = Vector2(chosen_scale, chosen_scale)
	dynamic_map.scale = Vector2(chosen_scale, chosen_scale)
	
	if !static_map.has_drawn:
		static_map.paths = paths
		static_map.water_bodies = water_bodies
		static_map.map = map
		static_map.terrain = terrain
		static_map.races = map.get_node("Objects/Races")
		static_map.autoshops = map.get_node("Objects/Autoshops")
		static_map.queue_redraw()

func _process(delta: float) -> void:
	var pos := Vector2.ZERO
	var pc = global.player_car
	if pc != null: pos = Vector2(pc.global_position.x, pc.global_position.z)
	
	dynamic_map.center = pos
	dynamic_map.queue_redraw()
	
	update_offset(-pos)
