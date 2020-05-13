extends Node2D

onready var completed_dialog = $Control/WindowDialog

var map_sprite
var dots = []
var finished = false

func _ready():
	load_map(5, false)
	move_mouse_to_start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !finished:
		update_game_state()
		
		# Updates the draw function
		update()


func _draw():
	var cen = get_viewport().get_mouse_position()
	var rad = 25
	var col = Color(0, 1, 0) if is_mouse_on_track() else Color(1, 0, 0)
	draw_circle (cen, rad, col)
	
	dots.append(cen)
	if len(dots) == 2:
		dots[0] = dots[1]
		
	for i in range(len(dots) - 2):
		draw_line(dots[i], dots[i+1],  Color(1, 0, 0), 10)

func game_over():
	move_mouse_to_start()
	dots = []
	

func update_game_state():
	if !is_mouse_on_track():
		game_over()
	elif get_viewport().get_mouse_position().x > 1900:
		completed_dialog.popup()
		finished = true
		print("COMPLETED!")


func move_mouse_to_start():
	var start_position = Vector2(40, get_viewport().size.y / 2)
	Input.warp_mouse_position(start_position)


func load_map(index=null, visible=true):
	# if no index is given -> generate an random index
	map_sprite = Sprite.new()
	randomize()
	if !index:
		var map_count = count_files_in_dir("res://Scenes/Mini Games/Cut/Maps/")
		print(map_count)
		index = randi() % map_count + 1

	var map = "res://Scenes/Mini Games/Cut/Maps/Map%s.jpeg" % index
	map_sprite.texture = load(map)
	if visible:
		map_sprite.centered = false
		map_sprite.show_behind_parent = true
		add_child(map_sprite)
	else:
		var metal_sprite = Sprite.new()
		metal_sprite.texture = load("res://Textures/metal-background.jpg")
		metal_sprite.centered = false
		metal_sprite.show_behind_parent = true
		add_child(metal_sprite)


func is_mouse_on_track():
	var pixelcolor = get_mouse_pixel_color()
	return pixelcolor != Color(1, 1, 1)


func get_mouse_pixel_color():

	var vec = get_viewport().get_mouse_position()
	var map_tex = map_sprite.texture.get_data()
	
	map_tex.lock()
	var pixelcolor = map_tex.get_pixelv(vec)
	map_tex.unlock()
	
	return pixelcolor

func count_files_in_dir(path):
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
	# divide by 2 because every map has an import file behind the scenes
	return count / 2
