extends Node2D

onready var completed_dialog = $Control/WindowDialog

var map_sprite
var dots = []
var finished = false
var start_position

func _ready():
	start_position =  Vector2(40, get_viewport().size.y / 2)
	_load_map(5, false)
	_move_mouse_to_start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !finished:
		_update_game_state()
		
		# Updates the draw function
		update()


func _draw():
	# Draw current pointer
	var cen = _get_mouse_pos()
	var rad = 25
	var col = Color(0, 1, 0) if _is_mouse_on_track() else Color(1, 0, 0)
	draw_circle(cen, rad, col)
	
	# Draw line
	if len (dots) == 0 or !dots[len(dots)-1] == cen:
		dots.append(cen)
	
	# Remove first incorrect dot (unaccurate warp mouse position when moving)	
	if len(dots) == 2:
		dots[0] = dots[1]
	
	for i in range(len(dots) - 2):
		draw_line(dots[i], dots[i+1],  Color(1, 0, 0), 10)
		
	# Draw Start Point
	draw_circle(Vector2(65, 540), 40, Color(0, 0, 1))

func _game_over():
	_move_mouse_to_start()
	dots.clear()
	

func _update_game_state():
	if !_is_mouse_on_track():
		_game_over()
	elif _get_mouse_pos().x > 1900:
		_game_completed()

func _game_completed():
	completed_dialog.popup()
	finished = true
	print("COMPLETED!")

func _move_mouse_to_start():
	Input.warp_mouse_position(start_position)


func _load_map(index=null, visible=true):
	# if no index is given -> generate an random index
	map_sprite = Sprite.new()
	randomize()
	if !index:
		var map_path = "res://Scenes/Mini Games/Cut/Maps/"
		# divide by 2 because every map has an import file behind the scenes
		var map_count = _count_files_in_dir(map_path) / 2
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


func _is_mouse_on_track():
	var pixelcolor = _get_mouse_pixel_color()
	return pixelcolor != Color(1, 1, 1)

func _get_mouse_pos():
	return get_viewport().get_mouse_position()
	
func _get_mouse_pixel_color():
	var vec = _get_mouse_pos()
	var map_tex = map_sprite.texture.get_data()
	
	map_tex.lock()
	var pixelcolor = map_tex.get_pixelv(vec)
	map_tex.unlock()
	return pixelcolor

func _count_files_in_dir(path):
	var count = 0
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			count += 1

	dir.list_dir_end()
	return count
