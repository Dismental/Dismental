extends Node2D

const Utils = preload("res://Script/Utils.gd")

var map_sprite

func _ready():
	print("start tracking scene")

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
	if true:
		var pos = get_node("HeadPos").position
		# Add a margin/multiplier so the user's movement is amplified.
		# The makes it easy for the user to reach the edges of the game screen with the pointer
		var margin = 0.4
		var windowmarginx = (OS.get_window_size().x)*margin
		var windowmarginy = (OS.get_window_size().y)*margin
		# Set the pointer position with the modified tracking position
		cursorpos = Vector2(pos.x*((OS.get_window_size().x*2) + windowmarginx)-(windowmarginx/2),
				pos.y*((OS.get_window_size().y*2)+windowmarginy)-(windowmarginy/2))
	else:
		cursorpos = get_global_mouse_position()
	return cursorpos
