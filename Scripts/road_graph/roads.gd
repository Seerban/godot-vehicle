extends Node3D
class_name RoadGraph

@export var width := 10
@export var height := 0.5
@export var points : Array[Vector3] 
@export var roads : Dictionary[int, int]
@export var road_material : StandardMaterial3D

var radar : Radar

func forms_plane(node: Node3D, epsilon: float = 0.001, max_slope_deg := 10.0) -> bool:
	var points_plane = node.connections.duplicate()

	if node not in points_plane:
		points_plane.append(node)

	var points_pos : Array[Vector3] = []
	for i in points_plane:
		points_pos.append(i.global_position)

	if points_pos.size() < 3:
		return true

	# Find 3 non-collinear points
	var p0 = points_pos[0]
	var p1 := Vector3.ZERO
	var p2 := Vector3.ZERO
	var found := false

	for i in range(1, points_pos.size() - 1):
		for j in range(i + 1, points_pos.size()):
			var v1 = points_pos[i] - p0
			var v2 = points_pos[j] - p0
			if v1.cross(v2).length() > epsilon:
				p1 = points_pos[i]
				p2 = points_pos[j]
				found = true
				break
		if found:
			break
	
	if not found:
		return true

	var plane := Plane(p0, p1, p2)
	
	var normal := plane.normal.normalized()
	var angle_from_up := rad_to_deg(
	acos(clamp(abs(normal.dot(Vector3.UP)), -1.0, 1.0)) # trig magic for steepness
	)

	if angle_from_up > max_slope_deg:
		return false

	# Distance test
	for p in points_pos:
		if abs(plane.distance_to(p)) > epsilon:
			return false
	
	return true

func symmetrize_graph() -> void:
	for i in get_children():
		for j in i.connections:
			if i not in j.connections:
				j.connections.append(i)

func add_road(from, to) -> void:
	var road = load("res://Scenes/road_graph/road_segment.tscn").instantiate() as StaticBody3D
	add_child(road)
	var length = from.distance_to( to )
	road.global_position = (from + to) / 2
	road.scale = Vector3(width, height, length)
	road.look_at(to)
	
	#add_road_cap(from, width, road.rotation)
	#add_road_cap(to, width, road.rotation)

# Only to be used with plane forming nodes
func add_road_cap(node : Node3D) -> void:
	var cap = load("res://Scenes/road_graph/road_cap.tscn").instantiate() as StaticBody3D
	add_child(cap)
	cap.global_position = node.global_position
	cap.look_at( node.connections[0].global_position )
	cap.scale = Vector3(width, height, width)

func init_from_children() -> void:
	var id = 0
	for i in get_children():
		i.id = id
	for i in get_children():
		for j in i.connections:
			if i == j: continue
			if j.id < i.id: continue # Avoid doubly adding road if node is already processed
			
			# Add to radar for drawing
			radar.connections.append(	
				[ Vector2(i.global_position.x, i.global_position.z),
				  Vector2(j.global_position.x, j.global_position.z)] )
			
			# Spawn road segment
			add_road(i.global_position, j.global_position)
		
		if len(i.connections) >= 2 and forms_plane(i): # 3 points with self included to form plane
			add_road_cap(i)
		
		i.queue_free()
		id += 1

func _ready() -> void:
	symmetrize_graph()
	radar = get_tree().get_first_node_in_group("radar")
	init_from_children()
