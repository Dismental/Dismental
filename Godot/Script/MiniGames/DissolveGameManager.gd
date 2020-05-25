extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var matrix = []
var columns = 160
var rows = 90
var heatmap_sprite = _init_heatmap_sprite()

var increase_factor = 5
var decrease_factor = 0.1

# Entry of matrix is range 0..2

var colors = [
	[0,0,255], # Blue
	[255,0,0], # Red
]

# Called when the node enters the scene tree for the first time.
func _ready():
	var x = get_viewport().size.x
	var y = get_viewport().size.y
	var column_width = x / float(columns)
	var row_width = y / float(rows)
	for _i in range(rows):
		var row = []
		for _j in range(columns):
			row.append(0)
		matrix.append(row)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_increase_matrix_input(delta)
	_refresh_heatmap()
	_decrease_heat(delta)

func _draw_sector(row, column, dyn_image):
	var vp = get_viewport_rect()
	var row_height = vp.size.y / rows
	var column_width = vp.size.x / columns
	var start_pixel_x = column_width * row
	var start_pixel_y = row_height * column
	for i in range(start_pixel_x, start_pixel_x + column_width):
		for j in range(start_pixel_y, start_pixel_y + row_height):
			dyn_image.set_pixel(i, j, Color(1, 0, 0, 1))


func _refresh_heatmap():
	var imageTexture = ImageTexture.new()
	var dyn_image = Image.new()
	var vp = get_viewport_rect()
	
	dyn_image.create(vp.size.x, vp.size.y, false, Image.FORMAT_RGB8)
	dyn_image.fill(Color(0, 1, 1, 1))
	dyn_image.lock()
	for r in range(rows):
		for c in range(columns):
			var temperature = matrix[r][c]
			_draw_sector(c, r, temperature, dyn_image)
	dyn_image.unlock()
	
	imageTexture.create_from_image(dyn_image)
	heatmap_sprite.set_texture(imageTexture)

func _decrease_heat(delta):
	for r in range(rows):
		for c in range(columns):
			matrix[r][c] -= decrease_factor * delta
			if matrix[r][c] < 0:
				matrix[r][c] = 0

func _draw_sector(row, column, temperature, dyn_image):
	var vp = get_viewport_rect()
	var row_height = vp.size.y / rows
	var column_width = vp.size.x / columns
	var start_pixel_x = column_width * row
	var start_pixel_y = row_height * column
	for i in range(start_pixel_x, start_pixel_x + column_width):
		for j in range(start_pixel_y, start_pixel_y + row_height):
			var blue = 1 / temperature / 100 * 255
			var red = temperature / 100 * 255
			dyn_image.set_pixel(i, j, Color(1, 0, 0, 1))


func _increase_matrix_input(delta):
	var vp = get_viewport_rect()
	var input = get_viewport().get_mouse_position()
	var input_x = clamp(input.x, 0, vp.size.x - 1)
	var input_y = clamp(input.y, 0, vp.size.y - 1)
	
	# Update matrix based on mouse position
	var sector = _get_sector(input_x, input_y)
	var row = sector.get("row")
	var column = sector.get("column")
	print(column, " " ,row)
	if matrix[row][column] < 100:
		matrix[row][column] += increase_factor * delta


func _init_heatmap_sprite():
	var imageTexture = ImageTexture.new()
	var dyn_image = Image.new()
	var vp = get_viewport_rect()
	dyn_image.create(vp.size.x, vp.size.y, false, Image.FORMAT_RGB8)
	dyn_image.fill(Color(0, 1, 1, 1))
	imageTexture.create_from_image(dyn_image)
	imageTexture.resource_name = "heatmap"
	var s = Sprite.new()
	s.centered = false
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
