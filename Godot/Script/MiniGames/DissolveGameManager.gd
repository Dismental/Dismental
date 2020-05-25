extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var matrix = []
var columns = 12
var rows = 6

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

	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# cursor position
	var vp = get_viewport_rect()
	
	
	# map -> matrix
	var input_x = get_viewport().get_mouse_position().x
	var input_y = get_viewport().get_mouse_position().y
	
	# Update matrix based on mouse position
	print(input_x)
	print(input_y)
	
	
	# Updated matrix, 2D array
	
	# Matrix -> image -> texture -> frame
	var imageTexture = ImageTexture.new()
	var dynImage = Image.new()
	dynImage.create(vp.size.x, vp.size.y, false, Image.FORMAT_RGB8)
	dynImage.fill(Color(0, 1, 1, 1))
	dynImage.lock()
	for i in range(vp.size.x / 2, vp.size.x / 2 + 10):
		for j in range(vp.size.y / 2, vp.size.y / 2 + 10):
			dynImage.set_pixel(i, j, Color(1, 0, 0, 1))
	dynImage.unlock()
	imageTexture.create_from_image(dynImage)
	
	imageTexture.resource_name = "heatmap"
	var s = Sprite.new()
	s.centered = false
	s.set_texture(imageTexture)
#	s.Texture = imageTexture
	add_child(s)
	print(s.get_texture())
	
	pass

# Give x and y, get sector of matrix the x and y is found in
# Returns [row, column]
func _get_sector(x, y):
	
	pass
