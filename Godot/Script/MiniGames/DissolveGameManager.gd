extends Node2D

var matrix = []
var columns = 128
var rows = 72
var heatmap_sprite

var increase_factor = 2
var decrease_factor = 6

var radius = 7

var background_color = Color(0, 0, 1, 1)

var soldering_iron_on = true 
var iron_label


func _ready():
	iron_label = get_node("SolderingIronLabel")
	
	heatmap_sprite = _init_heatmap_sprite()
	
	for _i in range(rows):
		var row = []
		for _j in range(columns):
			row.append(0)
		matrix.append(row)



func _process(delta):
	print(Engine.get_frames_per_second())
	if soldering_iron_on:
		_increase_matrix_input(delta)
	_refresh_heatmap(delta)

func _input(ev):
	if ev.is_action_pressed("space"):
		soldering_iron_on = not soldering_iron_on
		iron_label.text = "ON" if soldering_iron_on else "OFF"

func _refresh_heatmap(delta):

	var dyn_image = Image.new()
	var vp = get_viewport_rect()
	
	dyn_image.create(vp.size.x, vp.size.y, false, Image.FORMAT_RGB8)
	dyn_image.fill(background_color)
	dyn_image.lock()
	
	var row_height = vp.size.y / rows
	var column_width = vp.size.x / columns
	
	for r in range(rows):
		var start_pixel_y = row_height * r
		for c in range(columns):
			var start_pixel_x = column_width * c
			# Decrease temp
			matrix[r][c] -= decrease_factor * delta
			if matrix[r][c] < 0:
				matrix[r][c] = 0
			
			var temperature = matrix[r][c]
			if temperature > 5:
				for i in range(start_pixel_x, start_pixel_x + column_width):
					for j in range(start_pixel_y, start_pixel_y + row_height):
						var temp_scale = temperature / 100.0
						var red = temp_scale * 255.0
						var blue =  255.0 - (temp_scale * 255.0)
						dyn_image.set_pixel(i, j, Color(red / 100.0, 0, blue / 100.0, 1))


	dyn_image.unlock()
	heatmap_sprite.texture.create_from_image(dyn_image)






func _increase_matrix_input(delta):
	var vp = get_viewport_rect()
	var input = get_viewport().get_mouse_position()
	var input_x = clamp(input.x, 0, vp.size.x - 1)
	var input_y = clamp(input.y, 0, vp.size.y - 1)
	
	# Update matrix based on mouse position
	var sector = _get_sector(input_x, input_y)
	var row = sector.get("row")
	var column = sector.get("column")

	for y in range(column - radius, column + radius):
		for x in range(row - radius, row + radius):
			if Vector2(row, column).distance_to(Vector2(x, y)) < radius:
				var dis = Vector2(row, column).distance_squared_to(Vector2(x, y))
				
				if x >= 0 and x < rows and y >= 0 and y < columns:
					var ratio = pow(radius, 2) - dis
					matrix[x][y] += increase_factor * delta * ratio
					if matrix[x][y] > 100:
						matrix[x][y] = 100

func _init_heatmap_sprite():
	var imageTexture = ImageTexture.new()
	var dyn_image = Image.new()
	
	var vp = get_viewport_rect()
	dyn_image.create(vp.size.x, vp.size.y, false, Image.FORMAT_RGB8)
	dyn_image.fill(background_color)
	imageTexture.create_from_image(dyn_image)
	imageTexture.resource_name = "heatmap"
	var s = Sprite.new()
	s.centered = false
	s.show_behind_parent = true
	s.set_texture(imageTexture)
	add_child(s)
	return s


# Give x and y, get sector of matrix the x and y is found in
# Returns [row, column]
func _get_sector(input_x, input_y):
	var vp = get_viewport_rect()
	var row_height = vp.size.y / rows
	var column_width = vp.size.x / columns
	var row = floor(input_y / row_height)
	var column = floor(input_x / column_width)
	return { "row": row, "column": column }
