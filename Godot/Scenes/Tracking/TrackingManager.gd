extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum ROLE{
	notSet,
	head,
	hand,
	mouse,
	debug
}

enum MOVEMENT{
	aligned
	throttled
	lost
}

var role

var tracking_node
var pointer_node
var tracking_pos

var distance_from_free_zone

var lost_tracking

var free_movement_zone_radius = 100
var throttle_zone_radius = 200
var free_movement_zone_warp = 1
var throttle_zone_warp = 1

var delta_angle = 0
var delta_distance = 0
var movement_speed = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pointer_node = get_node("Pointer")
	lost_tracking = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (role == ROLE.debug):
		
		var tracking_pos_new = _map_tracking_position(tracking_node.position)
		var distance_new = (tracking_pos_new.distance_to(tracking_pos))
		
		delta_angle = atan2(tracking_pos_new.y - tracking_pos.y, tracking_pos_new.x - tracking_pos.x)
		delta_distance = tracking_pos.distance_to(tracking_pos_new)
		
		free_movement_zone_warp = max(1, min(4, (movement_speed.length()) / 500))
		throttle_zone_warp = max(1, min(4, (movement_speed.length()) / 1000))
		
		movement_speed = (tracking_pos_new - tracking_pos) / _delta
#		print(movement_speed.length())
		
		if (distance_new < 1):
			distance_new = 1
			

		if _within_free_movement_zone(tracking_pos, tracking_pos_new):
			if (lost_tracking): 
				lost_tracking = false
				free_movement_zone_radius = 100
				throttle_zone_radius = 200
				
			var position_offset = tracking_pos_new - tracking_pos
#			print(position_offset)
			
			tracking_pos = tracking_pos + (position_offset/6)
			pointer_node.position = tracking_pos
		elif _within_throttled_zone(tracking_pos, tracking_pos_new):
#			print("Throttled")
			var distance_outside_free_zone = distance_new - free_movement_zone_radius
			
			if (distance_outside_free_zone <= 0): distance_outside_free_zone = 1
			
			var position_offset = tracking_pos_new - tracking_pos
			var position_offset_norm = position_offset.normalized()
			var position_offset_limited_to_edge
			
			if (lost_tracking): 
				var inv_distance = 1/distance_outside_free_zone
				#TODO change this to a line towards the tracking position, indicating where the current tracking location is
				# Do this instead of slowly moving towards the tracking location as implemented below
				position_offset_limited_to_edge = position_offset_norm * 20 * (inv_distance * inv_distance)
			else:
				position_offset_limited_to_edge = position_offset_norm * _distance_to_free_zone_edge(tracking_pos, tracking_pos_new)
			
			tracking_pos = tracking_pos + (position_offset_limited_to_edge/6)
			pointer_node.position = tracking_pos
		else:
			if not (lost_tracking): 
#				print("Lost")
				lost_tracking = true
				free_movement_zone_radius = 25
				throttle_zone_radius = 100
			tracking_pos = tracking_pos
		
	elif (role == ROLE.head):
		tracking_pos = _map_tracking_position(tracking_node.position)
		pointer_node.position = tracking_pos
	elif (role == ROLE.mouseController):
		pointer_node.position = get_global_mouse_position()
#		print(pointer_node.position)
	
	update()


func _within_free_movement_zone(pos, pos_new):
	var distance = (pos.distance_to(pos_new))
	
	var ellipse_point = point_on_ellipse(delta_angle, delta_angle, free_movement_zone_radius, free_movement_zone_warp)
	
	print(ellipse_point.length())
	if (distance < ellipse_point.length()):
		return true
	return false


func _within_throttled_zone(pos, pos_new):
	var distance = (pos.distance_to(pos_new))
	
	var ellipse_point = point_on_ellipse(delta_angle, delta_angle, throttle_zone_radius, throttle_zone_warp)
	
	print(ellipse_point.length())
	if (distance < ellipse_point.length()):
		print("in throttle zone")
		return true
	return false

func _distance_to_free_zone_edge(pos, pos_new):
	return free_movement_zone_radius


func _set_role(_player_role):
	if (_player_role == ROLE.debug):
		print ("initiating debug tracking")
		var headTrackingScene = preload("res://Scenes/Tracking/HeadTracking.tscn")
		var tracking = headTrackingScene.instance()
		self.add_child(tracking)
		tracking_node = tracking.get_node("HeadPos")
		tracking_pos = _map_tracking_position(Vector2(0.5,0.5))
		role = _player_role
	elif (_player_role == ROLE.head):
		print ("initiating head tracking")
		var headTrackingScene = preload("res://Scenes/Tracking/HeadTracking.tscn")
		var tracking = headTrackingScene.instance()
		self.add_child(tracking)
		tracking_node = tracking.get_node("HeadPos")
		tracking_pos = _map_tracking_position(Vector2(0.5,0.5))
		role = _player_role
	elif (_player_role == ROLE.mouseController):
		print ("initiating mouse as pointer")
		role = _player_role
		
func _map_tracking_position(track_pos):
	var pointer_pos
		# The values for the headtracking position ranges from 0 to 1
	var pos = pointer_node.position
	# Add a margin/multiplier so the user's movement is amplified.
	# The makes it easy for the user to reach the edges of the game screen with the pointer
	var margin = 0.4
	var windowmarginx = (get_viewport_rect().size.x)*margin
	var windowmarginy = (get_viewport_rect().size.y)*margin
	# Set the pointer position with the modified tracking position
	pointer_pos = Vector2(track_pos.x*((get_viewport_rect().size.x) + windowmarginx)-(windowmarginx/2),
			track_pos.y*((get_viewport_rect().size.y)+windowmarginy)-(windowmarginy/2))
	return pointer_pos
	
func _on_Sprite_draw():
	print ("draw sprite")
	

func point_on_ellipse(angle, rotation, radius, warp):
	return Vector2(
		cos(rotation) * cos(angle) * (radius * warp) - sin(rotation) * sin(angle) * (radius),# + cos(rotation) * radius * (warp - 1) / 1.61803398875,
		cos(rotation) * sin(angle) * (radius) + sin(rotation) * cos(angle) * (radius * warp)# + sin(rotation) * radius * (warp - 1) / 1.61803398875
	)
	
func distance_from_origin(point):
	return point.distance_to(Vector2(0,0))
	
	
	
func _draw():
#	draw_circle(tracking_pos, throttle_zone_radius, Color(1, 1, 0))
#	draw_circle(tracking_pos, free_movement_zone_radius, Color(0, 1, 0))
	
#	print(delta_distance, warp_level)
	# draw throttle_movement_zone region
	for i in range(64):
		var theta = 2*PI/64*i
		var point_ellipse = point_on_ellipse(theta, delta_angle, throttle_zone_radius, throttle_zone_warp)
		
		draw_line(
			Vector2(tracking_pos.x, tracking_pos.y),
#			Vector2(tracking_pos.x - cos(theta + delta_angle) * radiusX, tracking_pos.y - sin(theta + delta_angle) * radiusY),
			Vector2(
				tracking_pos.x + point_ellipse.x,
				tracking_pos.y + point_ellipse.y
			),
			Color(255,255,0),
			4
		)
	
	# draw free_movement_zone region
	for i in range(64):
		var theta = 2*PI/64*i
		var point_ellipse = point_on_ellipse(theta, delta_angle, free_movement_zone_radius, free_movement_zone_warp)
		
		draw_line(
			Vector2(tracking_pos.x, tracking_pos.y),
#			Vector2(tracking_pos.x - cos(theta + delta_angle) * radiusX, tracking_pos.y - sin(theta + delta_angle) * radiusY),
			Vector2(
				tracking_pos.x + point_ellipse.x,
				tracking_pos.y + point_ellipse.y
			),
			Color(0,255,0),
			4
		)
		
	draw_circle(_map_tracking_position(tracking_node.position), 10, Color(255, 0, 0))
	draw_line(
		_map_tracking_position(tracking_node.position),
		tracking_pos,
		Color(255,0,0),
		4
	)
	
	
	
#	draw_line(
#		Vector2(tracking_pos.x - cos(PI/2 + delta_angle) * 100, tracking_pos.y - sin(PI/2 + delta_angle) * 100),
#		Vector2(tracking_pos.x + cos(PI/2 + delta_angle) * 100, tracking_pos.y + sin(PI/2 + delta_angle) * 100),
#		Color(0,255,0),
#		4
#	)
