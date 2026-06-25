class_name AITarget
extends Node3D

# direction along RoadPath
var direction = 1
# data of RoadPath obj
var curve: Curve3D
var points: PackedVector3Array
var target_path: RoadPath
var path_length: float

# AI vehicle targeting this obj
var vehicle: Vehicle

# how far ahead the target is
var advance_distance: float = 10.0
# 2.5 = one lane, 5 = two lanes
var right_offset: float = 2.5

var lane_change_time := 5.0
var lane_change_cooldown := 5.0
var lane_change_chance := 0.25

func _ready() -> void:
	if target_path == null: return
	if abs(direction) != 1: print("UNDEFINED DIRECTION FOR AITARGET!")
	
	curve = target_path.curve
	points = curve.get_baked_points()
	path_length = curve.get_baked_length()
	update_direction()
	direction *= -1
	
	# add debug mesh
	# var mesh := MeshInstance3D.new()
	# mesh.mesh = SphereMesh.new()
	# mesh.mesh.height = 2.5
	# add_child(mesh)

func _physics_process(delta: float) -> void:
	if !is_instance_valid(vehicle):
		print("Null parameter in AI Target!")
		set_physics_process(false)
		queue_free()
		return
	if curve == null:
		print("Null curve in AI Target!")
		set_physics_process(false)
		return
	
	# chance to switch lanes if possible
	update_lane(delta)
	# move target ahead on road
	update_target_position()

# if at the end of roadpath curve, look in data for following paths 
func advance_to_next_road() -> void:
	var followups: Array[RoadPath]
	
	if direction == -1: followups = target_path.followup_backward
	elif direction == 1: followups = target_path.followup_forward
	
	if len(followups) == 0:
		set_physics_process(false)
	
	var next_path = followups.pick_random()
	
	#print("advancing from %s to %s" % [target_path.name, next_path.name])
	
	target_path = next_path
	
	if target_path == null:
		global.disable_ai_car(vehicle)
		return
	
	curve = target_path.curve
	path_length = curve.get_baked_length()
	#print("NEXT PATH CHOSEN: ", target_path.name)

# checks which road end is closer and chooses a direction, used when switching road
func update_direction() -> void:
	var dist_to_start = (vehicle.global_position - curve.sample_baked(0.0)).length()
	var dist_to_fin = (vehicle.global_position - curve.sample_baked(curve.get_baked_length())).length()
	
	#print(vehicle.global_position, ' ', curve.sample_baked(0.0), ' ', vehicle.global_position - curve.sample_baked(curve.get_baked_length()))
	
	if dist_to_start < dist_to_fin: direction = 1.0
	else: direction = -1.0

# function for positioning target followed by car
func update_target_position() -> void:
	# compute position along road and forward position
	var projection_offset := curve.get_closest_offset(vehicle.global_position)
	var projection = curve.sample_baked(projection_offset)
	var projection_ahead_offset = projection_offset + advance_distance * direction
	var projection_ahead = curve.sample_baked(projection_ahead_offset)
	
	# get angle of road and right angle for computing offset to reach lane
	var angle = (curve.sample_baked(projection_ahead_offset) - curve.sample_baked(projection_offset)).normalized()
	var right_angle = angle.rotated(Vector3.UP, -PI/2)
	
	# project point to the right to reach chosen lane
	var projection_right = projection + right_angle * right_offset
	
	# get distance to point from vehicle
	var dist = (vehicle.global_position - projection_right).length()
	#  get distance perpendicular to the road angle
	var dist_x = (vehicle.global_position - projection_right).dot(right_angle)
	
	# move point to the opposite side of the road the AI vehicle is coming from
	# purpose is making the vehicle reach the road before starting to drive on the road and making turns smoother
	var final_right_offset = right_offset - dist_x / 3.0
	var projection_right_adjusted = projection + final_right_offset * right_angle
	
	# computer distance after perpendicular offset adjustment
	var final_ahead_distance = (vehicle.global_position - projection_right_adjusted).length()
	final_ahead_distance = clamp(advance_distance - final_ahead_distance, 0.0, advance_distance) * direction
	
	# set final position
	var target_pos = curve.sample_baked(projection_offset + final_ahead_distance) + right_angle * final_right_offset
	
	# if at end of road, check for possible next paths
	if (projection_ahead_offset >= path_length and direction == 1.0) or \
	   (projection_ahead_offset <= -1.0 and direction == -1.0):
		#print(" advancing at length ", target_pos, " out of ", path_length)
		advance_to_next_road()
		update_direction()
		return
		#print("CURRENT ROAD: ", target_path.name, " DIRECTION: ", direction, " TARGET POS", target_pos, " TARGET LENGTH: ", path_length)
	
	global_position = target_pos

# function to randomly switch lanes if possible (2 lanes per direction)
func update_lane(delta: float) -> void:
	if is_instance_valid(target_path): return
	
	# roaddouble or roadsimpledouble, will break if roadpath.type is changed
	if target_path.type not in [4, 5]:
		right_offset = 2.5
		return
	
	lane_change_cooldown -= delta
	if lane_change_cooldown <= 0.0:
		# random cooldown to create variance between AI vehicles
		lane_change_cooldown = lane_change_time * randf_range(0.8, 1.25)
		if randf() < lane_change_chance:
			# roads are 5 units wide, 2.5 and 7.5 represent middle of first and second lane
			if right_offset == 2.5: right_offset = 7.5
			else: right_offset = 2.5
