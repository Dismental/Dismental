extends Node2D

onready var start_dialog = $Control/StartDialog
onready var game_over_dialog = $Control/GameOverDialog
onready var completed_dialog = $Control/CompletedDialog

const Utils = preload("res://Script/Utils.gd")

var map_sprite
var dots = []
var running = false
var waitForStartingPosition = false
var start_position_input

var finish_rect

# 0 is on finsishbox
# 1 is clockwise
# -1 is counterclockwise
var finish_state = 0

func _ready():
	start_dialog.popup()
	_load_map(1,false)
	_calc_finish_line()


func _process(_delta):
	if running:
		_update_game_state()
		
		# Updates the draw function
		update()


func _draw():
	
	# Draw finish rect
	draw_rect(finish_rect, Color(0.5, 0.5, 0.5), 10)
	if running:
		var input_pos = _get_input_pos()
	
		# Add input pos to list of past input position
		# If the previous input position wasn't close
		if len (dots) == 0 or (dots[len(dots)-1].distance_to(input_pos) > 15):
			dots.append(input_pos)
	
	# Draw line
	if !waitForStartingPosition:
		for i in range(2, len(dots) - 1):
			draw_line(dots[i], dots[i+1],  Color(1, 0, 0), 10)
		
	# Draw Start Point
	#	var vp_rect = get_viewport_rect().size
	#	var start_point = Vector2(vp_rect.x * start_x_ratio, vp_rect.y/2)
	#	draw_circle(start_point, 50, Color(0, 0, 1))
	
	# Draw current pointer
	if len (dots) > 2:
		var rad = 15
		var col = Color(0, 1, 0) if _is_input_on_track() else Color(1, 0, 0)
		if running:
			draw_circle(_get_input_pos(), rad, col)
		else:
			draw_circle(dots[len(dots)-1], rad, col)


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			# Quits the game
			get_tree().quit()

func _calc_start_position():
	var center_x = finish_rect.position.x + (finish_rect.size.x * 0.5)
	var center_y = finish_rect.position.y + (finish_rect.size.y * 0.5)
	var center_rect = Vector2(center_x, center_y)
	
	var vp_size = get_viewport().size
	var vp_real_size = get_viewport_rect().size
	var ratio = vp_size / vp_real_size
	
	var offset_x = (OS.get_window_size().x - vp_size.x) / 2.0
	var offset_y = (OS.get_window_size().y - vp_size.y) / 2.0
	
	var start_pos = center_rect * ratio
	start_pos.x += offset_x
	start_pos.y += offset_y
	return start_pos


func _calc_finish_line():
	var start_x_ratio = 0.1
	var map_tex = map_sprite.texture
	var vp_rect = get_viewport_rect().size
	var sp = Vector2(vp_rect.x * start_x_ratio, vp_rect.y/2)

	# Find min x
	while(_get_map_pixel_color(sp) != Color(1, 1, 1)):
		sp.x -= 1
	var min_x = sp.x
	
	sp.x  = vp_rect.x * start_x_ratio
	
	# Find max x
	while(_get_map_pixel_color(sp) != Color(1, 1, 1)):
		sp.x += 1
	var max_x = sp.x
	
	var rect_height = 80
	finish_rect = Rect2(min_x, sp.y - rect_height/2, max_x - min_x, rect_height)


func _game_over():
	running = false
	game_over_dialog.popup()
	

func _update_game_state():

	if waitForStartingPosition:
		start_position_input = _calc_start_position()
		var distance_from_start = (start_position_input*2).distance_to(_get_input_pos())
		
		#print(_get_input_pos(), _calc_start_position(), distance_from_start)

		if distance_from_start < 10:
			waitForStartingPosition = false
			dots.clear()
		#print(typeof(start_position_input - _get_input_pos()))
		#check if current position is near the starting position

		# If the current position is near, check if a timer is running.
			# if the timer is not running, start it. if is running, check threshold
		
		# if the position is not near, cancel the timer
	if !waitForStartingPosition:
		if len(dots) > 2:
			if !_is_input_on_track():
				_game_over()
			else:
				_check_finish()


func _check_finish():
	if finish_state == 0:
		if !finish_rect.has_point(_get_input_pos()):
			if _get_input_pos().y < finish_rect.position.y:
				finish_state = 1
			else:
				finish_state = -1
				
	elif finish_state == 1:
		if finish_rect.has_point(_get_input_pos()):
			if dots[len(dots)-1].y > finish_rect.end.y:
				_game_completed()
			else:
				finish_state = 0
		
	elif finish_state == -1:
		if finish_rect.has_point(_get_input_pos()):
			if dots[len(dots)-1].y <= finish_rect.position.y:
				_game_completed()
			else:
				finish_state = 0


func _game_completed():
	completed_dialog.popup()
	running = false
	print("COMPLETED!")

func _move_input_to_start():
	start_position_input = _calc_start_position()
	Input.warp_mouse_position(start_position_input)


func _load_map(index=null, visible=true):
	# if no index is given -> generate an random index
	map_sprite = Sprite.new()
	randomize()
	if !index:
		var map_path = "res://Scenes/Mini Games/Cut/Maps/"
		# Divide by 2 because every map has an import file behind the scenes
		var map_count = Utils._count_files_in_dir(map_path) / 2
		print(map_count)
		index = randi() % map_count + 1

	var map = "res://Scenes/Mini Games/Cut/Maps/Map%s.jpeg" % index
	map_sprite.texture = load(map)
	if visible:
		_add_sprite_to_scene(map_sprite)
	else:
		var metal_sprite = Sprite.new()
		metal_sprite.texture = load("res://Textures/metal-background.jpg")
		_add_sprite_to_scene(metal_sprite)


func _add_sprite_to_scene(sprite):
	sprite.centered = false
	sprite.show_behind_parent = true
	add_child(sprite)


func _is_input_on_viewport():
	var input_pos = _get_input_pos()
	if input_pos.x >= 0 and input_pos.x <= get_viewport_rect().size.x:
		if input_pos.y >= 0 and input_pos.y <= get_viewport_rect().size.y:
			return true
	return false


func _is_input_on_track():
	if _is_input_on_viewport():
		var pixelcolor = _get_map_pixel_color(_get_input_pos())
		return pixelcolor != Color(1, 1, 1)
	return false


func _get_input_pos():
	# TODO get head tracking position
	# print(get_node("HeadPos").position)
	# var pos = get_node("HeadPos").position * 4
	# return Vector2(pos.x - 250, pos.y - 250)
	return get_global_mouse_position()


func _get_map_pixel_color(pos):
	var vec = pos
	var map_tex = map_sprite.texture.get_data()
	
	map_tex.lock()
	var pixelcolor = map_tex.get_pixelv(vec)
	map_tex.unlock()
	return pixelcolor


### BUTTON FUNCTIONALITIES ###
func _on_StartDialog_confirmed():
	running = true
	waitForStartingPosition = true
	start_position_input = _calc_start_position()
	


func _restart_game():
	waitForStartingPosition = true
	start_position_input = _calc_start_position()
	dots.clear()
	running = true


func _on_GameOverDialog_confirmed():
	_restart_game()


func _on_CompletedDialog_confirmed():
	get_tree().quit()
