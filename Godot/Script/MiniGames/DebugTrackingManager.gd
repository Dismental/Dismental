extends Node2D

onready var start_dialog = $Control/StartDialog
onready var game_over_dialog = $Control/GameOverDialog
onready var completed_dialog = $Control/CompletedDialog


const Utils = preload("res://Script/Utils.gd")

var map_sprite
var dots = []
var running = false
var waitForStartingPosition = true
var start_position_input

var finish_rect

# 0 is on finsishbox
# 1 is clockwise
# -1 is counterclockwise
var finish_state = 0

func _ready():
	print("start tracking scene")
	running = true
	start_position_input = true
	


func _process(_delta):
	if running:
		# Updates the draw function
		update()

func _draw():
	# Draw finish rect
	if running:
		var input_pos = _get_input_pos()
		# Add input pos to list of past input position
		# If the previous input position wasn't close
		if len(dots) == 0 or (dots[len(dots)-1].distance_to(input_pos) > 15):
			dots.append(input_pos)
	
	# Draw line
	for i in range(2, len(dots) - 1):
		draw_line(dots[i], dots[i+1],  Color(1, 0, 0), 10)
		
	# Draw Start Point
	#	var vp_rect = get_viewport_rect().size
	#	var start_point = Vector2(vp_rect.x * start_x_ratio, vp_rect.y/2)
	#	draw_circle(start_point, 50, Color(0, 0, 1))
	
	# Draw current pointer
	if len(dots) > 2:
		var rad = 25
		var col = Color(0, 1, 0)
		draw_circle(_get_input_pos(), rad, col)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			# Quits the game
			get_tree().quit()


func _add_sprite_to_scene(sprite):
	sprite.centered = false
	sprite.show_behind_parent = true
	add_child(sprite)

func _get_input_pos():
	var cursorpos
	# The values for the headtracking position ranges from 0 to 1
	if true:
		var pos = get_node("HeadPos").position
		# Add a margin/multiplier so the user can 'move' to the edge without actually moving its head to the edge
		var margin = 0.4
		var windowmarginx = (OS.get_window_size().x)*margin
		var windowmarginy = (OS.get_window_size().y)*margin
		cursorpos = Vector2(pos.x*((OS.get_window_size().x*2) + windowmarginx)-(windowmarginx/2), 
				pos.y*((OS.get_window_size().y*2)+windowmarginy)-(windowmarginy/2))
	else:
		cursorpos = get_global_mouse_position()
	return cursorpos
