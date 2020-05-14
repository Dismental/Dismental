extends Node2D

onready var start_dialog = $Control/StartDialog
onready var game_over_dialog = $Control/GameOverDialog
onready var completed_dialog = $Control/CompletedDialog

const Utils = preload("res://Script/Utils.gd")

var x_value_completed = 1900
var start_x_ratio = 0.07
var map_sprite
var dots = []
var running = false
var start_position

func _ready():
	start_dialog.popup()
	
	var vp_size = get_viewport().size
	start_position =  Vector2(vp_size.x * start_x_ratio, vp_size.y / 2)
	
	_load_map(2)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if running:
		# Updates the draw function
		update()
		_update_game_state()


func _draw():
	var mouse_pos = _get_mouse_pos()

	# Add mousepos to list of past mouse position
	# if the previous mouse position wasn't the same
	if len (dots) == 0 or !dots[len(dots)-1] == mouse_pos:
		dots.append(mouse_pos)
	
	# Draw line
	for i in range(2, len(dots) - 1):
		draw_line(dots[i], dots[i+1],  Color(1, 0, 0), 10)
		
	# Draw Start Point
	var vp_rect = get_viewport_rect().size
	var start_point = Vector2(vp_rect.x * start_x_ratio, vp_rect.y/2)
	draw_circle(start_point, 50, Color(0, 0, 1))
	
	# Draw current pointer
	if len (dots) > 2:
		var rad = 25
		var col = Color(0, 1, 0) if _is_mouse_on_track() else Color(1, 0, 0)
		draw_circle(mouse_pos, rad, col)


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			# Quits the game
			get_tree().quit()

func _game_over():
	running = false
	game_over_dialog.popup()
	

func _update_game_state():
	if len(dots) > 2:
		if !_is_mouse_on_track() or _get_mouse_pos().x < 0:
			_game_over()
		elif _get_mouse_pos().x > x_value_completed:
			_game_completed()

func _game_completed():
	completed_dialog.popup()
	running = false
	print("COMPLETED!")

func _move_mouse_to_start():
	Input.warp_mouse_position(start_position)


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

func _is_mouse_on_viewport():
	var mouse_pos = _get_mouse_pos()
	if mouse_pos.x >= 0 and mouse_pos.x <= get_viewport_rect().size.x:
		if mouse_pos.y >= 0 and mouse_pos.y <= get_viewport_rect().size.y:
			return true
	return false


func _is_mouse_on_track():
	if _is_mouse_on_viewport():
		var pixelcolor = _get_mouse_pixel_color()
		return pixelcolor != Color(1, 1, 1)
	return false

func _get_mouse_pos():
	return get_viewport().get_mouse_position()
	
func _get_mouse_pixel_color():
	var vec = _get_mouse_pos()
	var map_tex = map_sprite.texture.get_data()
	
	map_tex.lock()
	var pixelcolor = map_tex.get_pixelv(vec)
	map_tex.unlock()
	return pixelcolor


func _on_StartDialog_confirmed():
	running = true
	_move_mouse_to_start()

func _restart_game():
	_move_mouse_to_start()
	dots.clear()
	running = true

func _on_GameOverDialog_confirmed():
	_restart_game()


func _on_CompletedDialog_confirmed():
	get_tree().quit()
