extends Node2D

enum Role {
	NOTSET,
	HEAD,
	HAND,
	MOUSE,
	HEADTHROTTLE,
}

enum Movement {
	ALIGNED,
	THROTTLED,
	LOST,
}

var player_role

var tracking_node
var pointer_node
var tracking_pos
var pointer_pos
var pointer_pos_current

var distance_from_free_zone

var lost_tracking

var free_movement_zone_radius = 100
var throttle_zone_radius = 200
var free_movement_zone_warp = 1
var throttle_zone_warp = 1

var delta_angle = 0
var delta_angle_diff = 0
var movement_speed = Vector2(0,0)


func _ready():
	pointer_node = get_node("Pointer")
	lost_tracking = true


func _process(_delta):
	if player_role == Role.HEADTHROTTLE:
		var tracking_pos_new = _map_tracking_position(tracking_node.position)

		# The distance between the last tracking position and the new tracking position
		var distance_new = (tracking_pos_new.distance_to(tracking_pos))

		var delta_angle_old = delta_angle
		# The angle between the last tracking position and
		# the new tracking position e.g. the direction the tracking_pos moved
		delta_angle = atan2(
			tracking_pos_new.y - tracking_pos.y,
			tracking_pos_new.x - tracking_pos.x
		)
		# The difference between last angle and new angle
		# e.g. how much the direction changes
		delta_angle_diff = delta_angle - delta_angle_old

		# The current position of the pointer
		pointer_pos_current = pointer_node.position

		# The speed by which the pointer moves in pixels per second
		movement_speed = (pointer_pos_current - pointer_pos) / _delta

		# There are two zones: the free movement zone and the throttle zone
		# One can see the throttle zone as a 'warning zone' in which the speed
		# of the pointer is throttled
		# When outside of the throttle zone, the tracking will be lost
		# By applying this, the pointer is insensitive for sudden movements
		# by errors or faces of a bystander
		# The zones should allow more movement in the direction the pointer
		# is already moving and should be sensitive for sudden 'jumps'
		# In the ideal case the zones should resemble ellipses that are
		# warped according to the movement speed

		# Defining the warping of the free movement zone and the throttle zone
		if lost_tracking:
			free_movement_zone_warp = 1
			throttle_zone_warp = 1
		else:
			free_movement_zone_warp = max(1, min(4, movement_speed.length() / 100))
			throttle_zone_warp = max(1, min(4, movement_speed.length() / 200))

		distance_new = max(distance_new, 1)

		# Check if the new tracking position is inside of the free movement zone
		if _within_free_movement_zone(tracking_pos, tracking_pos_new):
			if (lost_tracking):
				lost_tracking = false
				free_movement_zone_radius = 100
				throttle_zone_radius = 200

			var position_offset = tracking_pos_new - tracking_pos

			# Define the movement of the pointer in the direction
			# to tracking_pos according to the change of direction
			var factor = 2.5 + abs(sin(delta_angle_diff)) * 6
			if (movement_speed.length() < 200):
				tracking_pos += (position_offset/4)
			else:
				tracking_pos += (position_offset/factor)

			pointer_node.position = tracking_pos
		# check if the new tracking position is inside of the throttle zone
		elif _within_throttled_zone(tracking_pos, tracking_pos_new):
			var distance_outside_free_zone = distance_new - free_movement_zone_radius

			if (distance_outside_free_zone <= 1): distance_outside_free_zone = 1

			var position_offset = tracking_pos_new - tracking_pos
			var position_offset_norm = position_offset.normalized()

			if not lost_tracking:
				var pos_offset_edge = position_offset_norm * _distance_to_free_zone_edge()
				tracking_pos += pos_offset_edge/4
				pointer_node.position = tracking_pos
		# tracking is lost
		else:
			if not (lost_tracking):
				print("Lost" + ", " + var2str(pointer_pos_current))
				lost_tracking = true
				throttle_zone_radius = 100
			tracking_pos = tracking_pos
		pointer_pos = pointer_pos_current
	elif (player_role == Role.HEAD):
		tracking_pos = _map_tracking_position(tracking_node.position)
		pointer_node.position = tracking_pos
	elif (player_role == Role.MOUSE):
		pointer_node.position = get_global_mouse_position()
	update()


func _within_free_movement_zone(pos, pos_new):
	var distance = pos.distance_to(pos_new)

	# calculate the relevant point on the ellipse-shaped free movement zone
	var ellipse_point = point_on_ellipse(
		0,
		delta_angle,
		free_movement_zone_radius,
		free_movement_zone_warp
	)

	# check if the distance of pos is smaller than the radius of the point on the ellipse
	if (distance < ellipse_point.length()):
		return true
	return false


func _within_throttled_zone(pos, pos_new):
	var distance = pos.distance_to(pos_new)

	# calculate the relevant point on the ellipse-shaped free movement zone
	var ellipse_point = point_on_ellipse(0, delta_angle, throttle_zone_radius, throttle_zone_warp)

	# check if the distance of pos is smaller than the radius of the point on the ellipse
	if (distance < ellipse_point.length()):
		return true
	return false

func _distance_to_free_zone_edge():
	# calculate the relevant point on the ellipse-shaped free movement zone
	var ellipse_point = point_on_ellipse(
		delta_angle,
		delta_angle,
		free_movement_zone_radius,
		free_movement_zone_warp
	)
	return ellipse_point.length()


func set_role(_player_role):
	if _player_role == Role.HEADTHROTTLE or _player_role == Role.HEAD:
		if _player_role == Role.HEADTHROTTLE:
			print ("initiating head tracking with throttle")
		else:
			print ("initiating head tracking")

		var head_tracking_scene = preload("res://Scenes/Tracking/HeadTracking.tscn")
		var tracking = head_tracking_scene.instance()
		self.add_child(tracking)
		tracking_node = tracking.get_node("HeadPos")
		tracking_pos = _map_tracking_position(Vector2(0.5,0.5))
		pointer_node.position = _map_tracking_position(Vector2(0.5,0.5))
		pointer_pos = pointer_node.position
		pointer_pos_current = pointer_node.position
		player_role = _player_role

	elif _player_role == Role.MOUSE:
		print ("initiating mouse as pointer")
		player_role = _player_role


func _map_tracking_position(track_pos):

	# Add a margin/multiplier so the user's movement is amplified.
	# The makes it easy for the user to reach the edges of the game screen with the pointer
	var margin = 0.4
	var windowmarginx = (get_viewport_rect().size.x)*margin
	var windowmarginy = (get_viewport_rect().size.y)*margin

	# Set the pointer position with the modified tracking position
	var pointer_pos = Vector2(
		track_pos.x * ((get_viewport_rect().size.x) + windowmarginx) - (windowmarginx/2),
		track_pos.y * ((get_viewport_rect().size.y) + windowmarginy) - (windowmarginy/2)
	)
	return pointer_pos


# calculate the x and y of a point defined by 'angle'
# on an ellipse with center=0,0, a specific rotation, a radius and a level of warping
# this function is used for defining the boundries of an ellipse-shaped zone
func point_on_ellipse(angle, rotation, radius, warp):
	var c_rot = cos(rotation)
	var s_rot = sin(rotation)
	var c_ang = cos(angle)
	var s_ang = sin(angle)
	var n = 1.61803398875
	return Vector2(
		c_rot * c_ang * (radius * warp) - s_rot * s_ang * (radius) + c_rot * radius * (warp - 1) / n,
		c_rot * s_ang * (radius) + s_rot * c_ang * (radius * warp) + s_rot * radius * (warp - 1) / n
	)


func distance_from_origin(point):
	return point.distance_to(Vector2(0,0))


func _draw():
#	# draw free_movement_zone region
	draw_circle(_map_tracking_position(tracking_node.position), 10, Color(255, 0, 0))
	draw_line(
		_map_tracking_position(tracking_node.position),
		tracking_pos,
		Color(255,0,0),
		4
	)
