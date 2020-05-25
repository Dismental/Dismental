extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var matrix = []
var columns = 12
var rows = 6
var heatmap_sprite = _init_heatmap_sprite()

# Entry of matrix is range 0..2

var colors = [
	[178,0,0],
	[93,86,124],
	[0,34,201],
]

# Called when the node enters the scene tree for the first time.
func _ready():
	var x = get_viewport().size.x
	var y = get_viewport().size.y
	var column_width = x / columns
	var row_width = y / rows
	for _i in range(rows):
		var row = []
		for _j in range(columns):
			row.append(0)
		matrix.append(row)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var vp = get_viewport_rect()
	var input_x = get_viewport().get_mouse_position().x
	var input_y = get_viewport().get_mouse_position().y
	
	# Update matrix based on mouse position
	var sector = _get_sector(input_x, input_y)
	var row = sector.get("row")
	var column = sector.get("column")
	
	matrix[row][column] += 1 if matrix[row][column] < 100 else 0
	
	var imageTexture = ImageTexture.new()
	var dynImage = Image.new()
	
	dynImage.create(vp.size.x, vp.size.y, false, Image.FORMAT_RGB8)
	dynImage.fill(Color(0, 1, 1, 1))
	dynImage.lock()
	for r in range(rows):
		for c in range(columns):
			if matrix[r][c] > 50:
				_draw_sector(r, c, dynImage)
	dynImage.unlock()
	
	imageTexture.resource_name = "heatmap"
	imageTexture.create_from_image(dynImage)
	heatmap_sprite.set_texture(imageTexture)

func _draw_sector(x, y, dyn_image):
	var vp = get_viewport_rect()
	var row_height = vp.size.x / 12
	var column_width = vp.size.x / 12
	var start_pixel_x = column_width * x
	var start_pixel_y = row_height * y
	for i in range(start_pixel_x, start_pixel_x + column_width):
		for j in range(start_pixel_y, start_pixel_y + row_height):
			dyn_image.set_pixel(j, i, Color(1, 0, 0, 1))


func _init_heatmap_sprite():
	var imageTexture = ImageTexture.new()
	var dynImage = Image.new()
	var vp = get_viewport_rect()
	dynImage.create(vp.size.x, vp.size.y, false, Image.FORMAT_RGB8)
	dynImage.fill(Color(0, 1, 1, 1))
	imageTexture.resource_name = "heatmap"
	imageTexture.create_from_image(dynImage)
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
