extends Node2D

enum Role {
	NOTSET,
	HEAD,
	HAND,
	MOUSE,
	HEADTHROTTLE,
}

var player_role

var tracking_node
var pointer_node
var tracking_pos
var pointer_pos
var pointer_pos_current

# Properties for the drawing of the pointer
var p_visible = true
var p_color = Color(0, 1, 1, 1)
var p_rad = 25

# Properties for the drawing of the pointer
var ptimer_activated = false
var ptimer_color = Color(1, 0, 0)
var ptimer_rad = 50
var ptimer_rad_loading = 50

# Properties for the drawing of the tracked position
var t_visible = true
var t_a = 1.0
var t_a_increase = false;
var t_rad = 10


# Properties for the interaction timer of the pointer
var time_to_interaction = 0
var time_to_interaction_total = 0

var distance_from_free_zone

export var pickup_pointer = true;

var free_movement_zone_radius = 100
var throttle_zone_radius = 200
var free_movement_zone_warp = 1
var throttle_zone_warp = 1

var delta_angle = 0
var delta_angle_diff = 0
var movement_speed = Vector2(0,0)


func _ready():
	pointer_node = get_node("Pointer")
	_on_pickupointer(true)

	p_visible = false
	t_visible = false


func _process(_delta):
	# Update interaction timer if a timer total is set (time > 0)
	if (time_to_interaction_total > 0):
		time_to_interaction += _delta
	# Check if the timer passed the limit
	if (time_to_interaction > time_to_interaction_total):
		time_to_interaction_total = 0
		time_to_interaction = 0

	_update_loading_interaction()

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
		if pickup_pointer:
			free_movement_zone_warp = 1
			throttle_zone_warp = 1
		else:
			free_movement_zone_warp = max(1, min(4, movement_speed.length() / 100))
			throttle_zone_warp = max(1, min(4, movement_speed.length() / 200))

		distance_new = max(distance_new, 1)

		# Check if the new tracking position is inside of the free movement zone
		if _within_free_movement_zone(tracking_pos, tracking_pos_new):
			if (pickup_pointer):
				_on_pickupointer(false)
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

			if not pickup_pointer:
				var pos_offset_edge = position_offset_norm * _distance_to_free_zone_edge()
				tracking_pos += pos_offset_edge/4
				pointer_node.position = tracking_pos
		# tracking is lost
		else:
			if not (pickup_pointer):
				print("Lost" + ", " + var2str(pointer_pos_current))
				_on_pickupointer(true)
				throttle_zone_radius = 40
				free_movement_zone_radius = 40
			tracking_pos = tracking_pos
		pointer_pos = pointer_pos_current

	elif (player_role == Role.HEAD):
		tracking_pos = _map_tracking_position(tracking_node.position)
		pointer_node.position = tracking_pos
	elif (player_role == Role.MOUSE):
		pointer_node.position = get_global_mouse_position()
	
	if t_a_increase:
		t_a += 0.1
		t_a_increase = t_a <= 1;
	else:
		t_a -= 0.1
		t_a_increase = t_a <= -1;
	$Pointer/Lbl_warning.add_color_override("font_color", _get_warning_color())
	update()

func _update_loading_interaction():
	if (time_to_interaction_total > 0):
		var time_passed = time_to_interaction / time_to_interaction_total
		var rad_diff = ptimer_rad - p_rad
		ptimer_rad_loading = p_rad + (rad_diff * time_passed)

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
	set_role_and_position(_player_role, Vector2(0.5,0.5))

func set_role_and_position(_player_role, start_pos):
	if _player_role == Role.HEADTHROTTLE or _player_role == Role.HEAD:
		if _player_role == Role.HEADTHROTTLE:
			print ("initiating head tracking with throttle")
		else:
			print ("initiating head tracking")

		tracking_node = $HeadPos
		tracking_pos = _map_tracking_position(start_pos)
		pointer_node.position = _map_tracking_position(start_pos)
		pointer_pos = pointer_node.position
		pointer_pos_current = pointer_node.position
		player_role = _player_role
		p_visible = true
		t_visible = true
	elif _player_role == Role.MOUSE:
		print ("initiating mouse as pointer")
		player_role = _player_role


func _map_tracking_position(track_pos):
	# Add a margin/multiplier so the user's movement is amplified.
	# The makes it easy for the user to reach the edges of the game screen with the pointer
	var margin = 0.6
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
	# Draw the tracked position
	if pickup_pointer:
		draw_circle(_map_tracking_position(tracking_node.position), t_rad, _get_t_color())
		draw_line(
			_map_tracking_position(tracking_node.position),
			tracking_pos,
			_get_t_color(),
			4
		)

	if (ptimer_activated):
		draw_circle(pointer_node.position , ptimer_rad_loading, ptimer_color)

	# Draw the pointer
	if (p_visible):
		if pickup_pointer:
			draw_circle(pointer_node.position , p_rad + abs(cosh(t_a))*10, p_color)

		else:
			draw_circle(pointer_node.position , p_rad, p_color)

func set_pointer_radius(rad):
	p_rad = rad

func set_pointer_color(col):
	p_color = col
	
func _get_t_color():
	return Color(1.0, 0.0, 0.0, -0.5)

func _get_warning_color():
	return Color(1.0, 0.0, 0.0, abs(t_a/2.0)+0.5)

func interaction_timer_activate(_timer):
	if (_timer > 0):
		time_to_interaction_total = _timer
		time_to_interaction = 0
		ptimer_activated = true

func interaction_timer_deactivate():
	time_to_interaction_total = 0
	ptimer_activated = false

func interaction_timer_is_active():
	return ptimer_activated

func interaction_timer_is_finished():
	if (ptimer_activated and time_to_interaction_total == 0):
		return true
	return false

func _on_pickupointer(value):
	$VBoxContainer/Lbl_pickup_pointer.visible = value
	$Pickuppointershadow.visible = value
	pickup_pointer = value


func _on_HeadPos_losttracking_changed(value):
	$VBoxContainer/Lbl_lost_tracking.visible = value
	$Pointer/Lbl_warning.visible = value


func _on_HeadPos_multiface_changed(value):
	pass # Replace with function body.


func _on_HeadPos_templatematching_changed(value):
	$VBoxContainer/Lbl_template_matching.visible = value
	$VBoxContainer/Lbl_lighting.visible = value
	$Pointer/Lbl_warning.visible = value


func _on_HeadPos_tooclose_changed(value):
	$VBoxContainer/Lbl_too_close.visible = value
	$Pointer/Lbl_warning.visible = value
