extends Node2D

var map_sprite
var tracking_node

func _ready():
	print("start tracking scene")

	# Initialize the HeadTracking scene
	var HeadTrackingScene = preload("res://Scenes/Tracking/HeadTracking.tscn")
	var head_tracking = HeadTrackingScene.instance()
	self.add_child(head_tracking)
	tracking_node = head_tracking.get_node("Position2D");

func _process(_delta):
	# Updates the draw function
	update()

func _draw():
	# Get cursor position
	var input_pos = _get_input_pos()

	# Draw current pointer at cursor position
	var rad = 25
	var col = Color(0, 1, 0)
	draw_circle(input_pos, rad, col)

func _unhandled_input(event):
	# Quit the game when escape is pressed
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			# Quits the game
			get_tree().quit()

func _get_input_pos():
	var cursorpos
	# The values for the headtracking position ranges from 0 to 1
	var pos = tracking_node.position
	# Add a margin/multiplier so the user's movement is amplified.
	# The makes it easy for the user to reach the edges of the game screen with the pointer
	var margin = 0.4
	var windowmarginx = (get_viewport_rect().size.x)*margin
	var windowmarginy = (get_viewport_rect().size.y)*margin
	# Set the pointer position with the modified tracking position
	cursorpos = Vector2(pos.x*((get_viewport_rect().size.x) + windowmarginx)-(windowmarginx/2),
			pos.y*((get_viewport_rect().size.y)+windowmarginy)-(windowmarginy/2))

	return cursorpos
