extends Node2D

const Role = preload("res://Script/Role.gd")

puppet var puppet_mouse = Vector2()

# Constants for the properties of the x-ray vision texture
const supervisor_shadow_width = 800
const supervisor_shadow_height = 600
const supervisor_shadow_scalex = 5
const supervisor_shadow_scaley = supervisor_shadow_scalex

var map_sprite
var dots = []
var running = false
var waitForStartingPosition = true
var pointer_node

var finish_rect

# 0 is on finsishbox
# 1 is clockwise
# -1 is counterclockwise
var finish_state = 0
var player_role

onready var start_dialog = $Control/StartDialog
onready var game_over_dialog = $Control/GameOverDialog
onready var completed_dialog = $Control/CompletedDialog
onready var supervisor_vision = $"Control/X-rayVision"

func _ready():
	supervisor_vision.visible = true
	
	player_role = Role.DEFUSER if get_tree().is_network_server() else Role.SUPERVISOR
	
	if player_role == Role.DEFUSER:
		start_dialog.popup()
		_load_map(1, false)
		
		# Initialize the HeadTracking scene for this user
		print("start tracking scene")
		var PointerScene = preload("res://Scenes/Tracking/Pointer.tscn")
		var pointer = PointerScene.instance()
		self.add_child(pointer)
		var pointer_control = pointer.get_node(".")
		pointer_control.set_role(pointer.ROLE.HEADTHROTTLE)
		pointer_node = pointer.get_node("Pointer")
		
		# Turn the x-ray vision OFF for the operator
		supervisor_vision.visible = false
	else:
		_load_map(1)
		# Turn the x-ray vision ON for the operator
		supervisor_vision.visible = true
		# Center the x-ray vision
		_supervisor_vision_update(Vector2(OS.get_window_size().x, OS.get_window_size().y))
	_calc_finish_line()


func _process(_delta):
	if running:
		_update_game_state()

		# Updates the draw function
		update()


func _draw():
	# Draw finish rect
	draw_rect(finish_rect, Color(0.5, 0.5, 0.5), 10)
	if running and not waitForStartingPosition:
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
	#	var start_point = Vector2(vp_rect.x * start_x_ratio,vp_rect.y/2)
	#	draw_circle(start_point, 50, Color(0, 0, 1))
	
	# Draw current pointer
	var rad = 25
	var col = Color(1, 0, 0) if not _is_input_on_track() and not waitForStartingPosition else Color(0, 1, 0)

	draw_circle(_get_input_pos(), rad, col)


func _supervisor_vision_update(pos):
	var shadow_pos = Vector2(0,0)

	# Handle edge cases if pos is outside the screen
	var x = clamp(pos.x, 0, get_viewport_rect().size.x)
	var y = clamp(pos.y, 0, get_viewport_rect().size.y)
	
	# Position the center of x-ray shadow texture at the 'pos' input location
	shadow_pos.x = x - supervisor_shadow_width * supervisor_shadow_scalex / 2.0
	shadow_pos.y = y - supervisor_shadow_height * supervisor_shadow_scaley / 2.0

	supervisor_vision.set_position(shadow_pos)


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			# Quits the game
			get_tree().quit()


func _calc_start_position():
	var center_x = finish_rect.position.x + (finish_rect.size.x / 2.0)
	var center_y = finish_rect.position.y + (finish_rect.size.y / 2.0)
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
	if player_role == Role.DEFUSER:
		game_over_dialog.popup()
	rpc("_on_update_running", false)


func _update_game_state():
	if waitForStartingPosition:
		var start_position_input = _calc_start_position()
		var distance_from_start = (start_position_input*2).distance_to(_get_input_pos())
		if distance_from_start < 10:
			waitForStartingPosition = false
			dots.clear()
	else:
		if len(dots) > 2:
			if not _is_input_on_track():
				_game_over()
			else:
				_check_finish()
	# Move the 'vision' of the Supervisor
	if running and not player_role == Role.DEFUSER:
		_supervisor_vision_update(get_global_mouse_position())


func _check_finish():
	if finish_state == 0:
		if not finish_rect.has_point(_get_input_pos()):
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
	rpc("_on_update_running", false)
	rpc("_on_game_completed")

func _move_input_to_start():
	var start_position_input = _calc_start_position()
	if player_role == Role.DEFUSER:
		Input.warp_mouse_position(start_position_input)


func _load_map(index=null, visible=true):
	# if no index is given -> generate an random index
	map_sprite = Sprite.new()
	randomize()
	if not index:
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
	var cursorpos
	if player_role == Role.DEFUSER:
		cursorpos = pointer_node.position
		rset("puppet_mouse", cursorpos)
	else:
		cursorpos = puppet_mouse
	return cursorpos


func _get_map_pixel_color(pos):
	var vec = pos
	var map_tex = map_sprite.texture.get_data()
	
	map_tex.lock()
	var pixelcolor = map_tex.get_pixelv(vec)
	map_tex.unlock()
	return pixelcolor


### BUTTON FUNCTIONALITIES ###
func _on_StartDialog_confirmed():
	rpc("_on_update_running", true)

func _on_GameOverDialog_confirmed():
	rpc("_on_game_over")

func _on_CompletedDialog_confirmed():
	rpc("_on_game_completed")
	

remotesync func _on_game_over():
	get_tree().get_root().get_node("GameScene").game_over()
	get_parent().call_deferred("remove_child", self)


remotesync func _on_update_running(newValue):
	running = newValue


remotesync func _on_game_completed():
	get_parent().call_deferred("remove_child", self)

