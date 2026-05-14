class_name AITarget
extends Node3D

var direction = 1 # 1 = regular, -1 = opposite, other undefined
var curve: Curve3D
var points: PackedVector3Array
var target_path: Path3D
var path_length: float
var vehicle: Vehicle

# how far ahead the target is
var advance_distance: float = 10.0
# 2.5 = one lane, 5 = two lanes
var right_offset: float = 2.5

func _ready() -> void:
	if target_path == null: return
	if abs(direction) != 1: print("UNDEFINED DIRECTION FOR AITARGET!")
	
	curve = target_path.curve
	points = curve.get_baked_points()
	path_length = curve.get_baked_length()
	update_direction()
	
	# add debug mesh
	var mesh := MeshInstance3D.new()
	mesh.mesh = SphereMesh.new()
	mesh.mesh.height = 2.5
	add_child(mesh)

func _physics_process(delta: float) -> void:
	if vehicle == null:
		print("Null parameter in AI Target!")
		set_physics_process(false)
		return
	if curve == null:
		print("Null curve in AI Target!")
		set_physics_process(false)
		return
	
	update_target_position()

func advance_to_next_road() -> void:
	var followups: Array[RoadPath]
	
	if direction == -1: followups = target_path.followup_backward
	elif direction == 1: followups = target_path.followup_forward
	
	if len(followups) == 0:
		set_physics_process(false)
	
	var next_path = followups.pick_random()
	
	#print("advancing from %s to %s" % [target_path.name, next_path.name])
	
	target_path = next_path
	curve = target_path.curve
	path_length = curve.get_baked_length()
	#print("NEXT PATH CHOSEN: ", target_path.name)

func update_direction() -> void:
	var dist_to_start = (vehicle.global_position - curve.sample_baked(0.0)).length()
	var dist_to_fin = (vehicle.global_position - curve.sample_baked(curve.get_baked_length())).length()
	
	#print(vehicle.global_position, ' ', curve.sample_baked(0.0), ' ', vehicle.global_position - curve.sample_baked(curve.get_baked_length()))
	
	if dist_to_start < dist_to_fin: direction = 1.0
	else: direction = -1.0

func update_target_position() -> void:
	var projection := curve.get_closest_offset(vehicle.global_position)
	var dist = (curve.get_closest_point(vehicle.global_position) - vehicle.global_position).length()
	var ahead_distance = clamp(advance_distance - dist, 0.0, advance_distance)
	var target_pos: float = projection + ahead_distance * direction
	
	# if at end of road, check for possible next paths
	if (target_pos >= path_length and direction == 1.0) or (target_pos <= -1.0 and direction == -1.0):
		#print(" advancing at length ", target_pos, " out of ", path_length)
		advance_to_next_road()	
		update_direction()
		return
		#print("CURRENT ROAD: ", target_path.name, " DIRECTION: ", direction, " TARGET POS", target_pos, " TARGET LENGTH: ", path_length)
	
	# get road angle
	var pos := curve.sample_baked(target_pos, true)
	var ahead := curve.sample_baked( target_pos + 0.1 * direction, true)
	
	# get side vector to control which lane is driven on
	var forward := (ahead - pos).normalized()
	var right := forward.rotated(Vector3.UP, PI/2)
	
	var right_vehicle_offset = (pos - right * right_offset - vehicle.global_position).dot(right) * 0.35
	
	global_position = target_path.to_global( pos - right * right_offset + right * right_vehicle_offset )
