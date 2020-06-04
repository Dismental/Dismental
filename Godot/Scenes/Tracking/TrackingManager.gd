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
var throttle_zone_radius = 400

# Called when the node enters the scene tree for the first time.
func _ready():
	pointer_node = get_node("Pointer")
	lost_tracking = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (role == ROLE.debug):
		
		var tracking_pos_new = _map_tracking_position(tracking_node.position)
		var distance_new = (tracking_pos_new.distance_to(tracking_pos))

		if (distance_new < 1):
			distance_new = 1

		if _within_free_movement_zone(tracking_pos, tracking_pos_new):
			if (lost_tracking): 
				lost_tracking = false
				free_movement_zone_radius = 100
				throttle_zone_radius = 400
				
			var position_offset = tracking_pos_new - tracking_pos
			print(position_offset)
			
			tracking_pos = tracking_pos + (position_offset/6)
			pointer_node.position = tracking_pos
		elif _within_throttled_zone(tracking_pos, tracking_pos_new):
			print("Throttled")
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
				print("Lost")
				lost_tracking = true
				free_movement_zone_radius = 25
				throttle_zone_radius = 200
			tracking_pos = tracking_pos
		
	elif (role == ROLE.head):
		tracking_pos = _map_tracking_position(tracking_node.position)
		pointer_node.position = tracking_pos
	elif (role == ROLE.mouseController):
		pointer_node.position = get_global_mouse_position()
		print(pointer_node.position)


func _within_free_movement_zone(pos, pos_new):
	var distance = (pos.distance_to(pos_new))
	
	if (distance < free_movement_zone_radius):
		return true
	return false


func _within_throttled_zone(pos, pos_new):
	var distance = (pos.distance_to(pos_new))
	
	if distance < throttle_zone_radius:
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
