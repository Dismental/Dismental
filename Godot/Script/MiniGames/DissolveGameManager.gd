extends Node2D

const Role = preload("res://Script/Role.gd")

var matrix = []
var columns = 128
var rows = 72
var heatmap_sprite
var radius = 7

# Increase/decrease factor of temperature
var increase_factor = 12
var decrease_factor = 6

var soldering_iron_on = true
var iron_label

var parent_node_heatmap

# https://coolors.co/080c46-a51cad-d92e62-f8e03d-fefff9
# HSB / HSV colors
# Colors of the heatmap in HSV format
var colors = [
	[236.0, 90.0, 27.0],
	[297.0, 84.0, 68.0],
	[342.0, 79.0, 85.0],
	[52.0, 75.0, 97.0],
	[70.0, 2.0, 100.0],
]

var h_low = 0
var h_range = 0
var s_low = 0
var s_range = 0
var b_low = 0
var b_range = 0
var background_color = Color.from_hsv(0, 0, 0)

var player_role

func _ready():
	iron_label = get_node("SolderingIronLabel")
	parent_node_heatmap = get_node("Heatmap")
	
	player_role = Role.DEFUSER if get_tree().is_network_server() else Role.SUPERVISOR
	
	# Generate the heatmap for the supervisor only
	if player_role == Role.SUPERVISOR:
		heatmap_sprite = _init_heatmap_sprite()
		
		# Convert H to percentage
		for i in range(colors.size()):
			colors[i][0] = ((colors[i][0] * 100.0) / 360.0) / 100.0
		
		# Divide S & B by 100.0
		for i in range(colors.size()):
			for j in range(1, 3):
				colors[i][j] = colors[i][j] / 100.0
		
		var last_color_i = colors.size() - 1
		h_low = colors[0][0]
		h_range = 1.0 + colors[last_color_i][0]
		s_low = colors[0][1]
		s_range = abs(colors[last_color_i][1] - s_low)
		b_low = colors[0][2]
		b_range = abs(colors[last_color_i][2] - b_low)
		background_color = Color.from_hsv(colors[0][0], colors[0][1], colors[0][2])

	for _i in range(rows):
		var row = []
		for _j in range(columns):
			row.append(0)
		matrix.append(row)


func _process(delta):
	if soldering_iron_on:
		_increase_matrix_input(delta)
	if player_role == Role.SUPERVISOR:
		_refresh_heatmap(delta)


func _input(ev):
	# Turn the soldering iron on and off with the space bar
	if ev.is_action_pressed("space"):
		soldering_iron_on = not soldering_iron_on
		iron_label.text = "ON" if soldering_iron_on else "OFF"


# Decreases the matrix temperatures and creates a new image afterwards
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
						dyn_image.set_pixel(i, j, _pick_color(temperature))

	dyn_image.unlock()
	heatmap_sprite.texture.create_from_image(dyn_image)

# Increases matrix temperature values based on the input
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
					matrix[x][y] += (increase_factor / radius) * delta * ratio
					if matrix[x][y] > 100:
						matrix[x][y] = 100


# Give percentage in the range of 100%, returns the right color
func _pick_color(percentage):
	percentage = percentage / 100.0
	var h = fmod((h_low + percentage * h_range), 1.0)
	var s = s_low - percentage * s_range
	var b = b_low + percentage * b_range
	return Color.from_hsv(h, s, b)

# Create the heatmap sprite and add it to the scene
func _init_heatmap_sprite():
	var image_texture = ImageTexture.new()
	var dyn_image = Image.new()

	var vp = get_viewport_rect()
	dyn_image.create(vp.size.x, vp.size.y, false, Image.FORMAT_RGB8)
	dyn_image.fill(background_color)
	image_texture.create_from_image(dyn_image)
	image_texture.resource_name = "heatmap"
	var s = Sprite.new()

	s.centered = false
	s.set_texture(image_texture)
	parent_node_heatmap.add_child(s)

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


func _on_SolderingIron_mouse_entered():
	print("Mouse has entered soldering Iron")
