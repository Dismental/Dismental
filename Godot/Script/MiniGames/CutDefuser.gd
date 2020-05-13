extends Node2D

onready var start_dialog = $Control/StartDialog
onready var completed_dialog = $Control/CompletedDialog

const Utils = preload("res://Script/Utils.gd")

var x_value_completed = 1900
var map_sprite
var dots = []
var running = false
var start_position

func _ready():
	start_dialog.popup()
	start_position =  Vector2(40, get_viewport().size.y / 2)
	
	# Index of level, bool level visibility
	_load_map(4, false)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if running:
		# Updates the draw function
		update()
		_update_game_state()
		

func _draw():
	var mouse_pos = _get_mouse_pos()
	if running:
		# Add mousepots to list of coordinates
		if len (dots) == 0 or !dots[len(dots)-1] == mouse_pos:
			dots.append(mouse_pos)
	
	# Draw line
	for i in range(1, len(dots) - 2):
		draw_line(dots[i], dots[i+1],  Color(1, 0, 0), 10)
		
	# Draw Start Point
	draw_circle(Vector2(80, 540), 50, Color(0, 0, 1))
	
	if running:
		# Draw current pointer
		if len (dots) >= 2:
			var rad = 25
			var col = Color(0, 1, 0) if _is_mouse_on_track() else Color(1, 0, 0)
			draw_circle(mouse_pos, rad, col)


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()

func _game_over():
	_move_mouse_to_start()
	dots.clear()
	

func _update_game_state():
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
	if mouse_pos.x >= 0 and mouse_pos.x <= get_viewport().size.x:
		if mouse_pos.y >= 0 and mouse_pos.y <= get_viewport().size.y:
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

