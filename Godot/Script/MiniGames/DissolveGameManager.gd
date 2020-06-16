extends Node2D

enum DefuserState {
	OFF,
	SOLDERING_IRON,
	VACUUM
}

puppet var puppet_mouse = Vector2()

const Role = preload("res://Script/Role.gd")

var matrix
var columns = 90
var rows = 72
var heatmap_sprite
var radius = 9
var defuse_state = DefuserState.OFF

var pointer_node

# Increase/decrease factor of temperature
var increase_factor = 24
var decrease_factor = 3

var component_width = 120
var component_height = 30
var num_of_components = 6
var components = []

var vacuum_remove_threshold = 50

var blink_light
var is_blinking = false

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

var h_low
var h_range
var s_low
var s_range
var b_low
var b_range

var background_color

var player_role

var on_vacuum = false
var on_soldering = false

onready var soldering_iron_indicator = $SolderingBackground/SolderingIron
onready var iron_label = $SolderingBackground/SolderingIron/SolderingIronLabel

onready var vacuum_indicator = $VacuumBackground/Vacuum
onready var vacuum_label = $VacuumBackground/Vacuum/VacuumLabel

onready var motherboard = $MotherBoard
onready var title_label = $CanvasLayer/Title

onready var pointer_dot = $red_dot

func _ready():
	player_role = Role.DEFUSER if get_tree().is_network_server() else Role.SUPERVISOR

	# Generate the heatmap for the supervisor only
	if player_role == Role.SUPERVISOR:
		_init_matrix()
		_generate_blink_light()
		_generate_colors()
		_generate_color_scale()
		heatmap_sprite = _init_heatmap_sprite()
		_generate_components()

	elif player_role == Role.DEFUSER:
		# Initialize the pointer scene for this user
		var PointerScene = preload("res://Scenes/Tracking/Pointer.tscn")
		var pointer = PointerScene.instance()
		self.add_child(pointer)
		var pointer_control = pointer.get_node(".")
		pointer_control.set_role(pointer.Role.HEADTHROTTLE)
		pointer_node = pointer.get_node("Pointer")
		_generate_components()


func _process(delta):
	if player_role == Role.SUPERVISOR:
		if defuse_state == DefuserState.SOLDERING_IRON:
			_increase_matrix_input(delta)
		elif defuse_state == DefuserState.VACUUM:
			_check_vacuum()
		_refresh_heatmap(delta)
	else:
		_check_input()
	
	# Updates the draw function
	_update_dot()


func _update_dot():
	pointer_dot.position = _get_input_pos()

func _init_matrix():
	matrix = []
	for _i in range(rows):
		var row = []
		for _j in range(columns):
			row.append(0)
		matrix.append(row)

func _generate_colors():
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
	background_color.a = 0.4

func _generate_blink_light():
	blink_light = ColorRect.new()
	blink_light.color = Color(0.5, 0.5, 0.5, 1)

	var width = 100
	blink_light.set_begin(Vector2(110, 900))
	blink_light.set_end(Vector2(110 + width, 900 + width))

	get_node("CanvasLayer").add_child(blink_light)

func _blink_light():
	blink_light.color = Color(1, 0, 0, 0.5)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	blink_light.color.a = 1
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	blink_light.color = Color(0.5, 0.5, 0.5, 1)
	is_blinking = false

func _generate_color_scale():
	var n = 0
	var width = 50
	for c in colors:
		var rec = ColorRect.new()
		rec.color = Color.from_hsv(c[0], c[1], c[2])
		rec.set_begin(Vector2(30 + n * width, 30))
		rec.set_end(Vector2(30 + (n + 1) * width, 30 + width))
		get_node("CanvasLayer").add_child(rec)
		n += 1

# Decreases the matrix temperatures and creates a new image afterwards
func _refresh_heatmap(delta):
	var dyn_image = Image.new()
	var mb = motherboard.rect_size

	dyn_image.create(mb.x, mb.y, false, Image.FORMAT_RGBA8)
	dyn_image.fill(background_color)

	dyn_image.lock()
	var row_height = mb.y / rows
	var column_width = mb.x / columns

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
	var mb_position = motherboard.rect_position
	var mb_size = motherboard.rect_size

	var input = _get_input_pos()

	if input.x - mb_position.x > 0 and input.x < mb_size.x - 1 + mb_position.x:
		if input.y - mb_position.y > 0 and input.y < mb_size.y - 1 + mb_position.y:

			# Update matrix based on input position
			var sector = _get_sector(input.x, input.y)

			var row = sector.get("row")
			var column = sector.get("column")

			for y in range(column - radius, column + radius):
				for x in range(row - radius, row + radius):
					var dis = Vector2(row, column).distance_to(Vector2(x, y))
					if dis < radius:
						if x >= 0 and x < rows and y >= 0 and y < columns:
							var ratio = (radius - dis + 1) / (radius + 1)
							matrix[x][y] += increase_factor * delta * ratio

							if matrix[x][y] > 80 and not is_blinking:
								is_blinking = true
								_blink_light()
							if matrix[x][y] > 100:
								matrix[x][y] = 100
								rpc("_game_over")

# Checks if the input cursor is in range of destroyable components
# Removes a component when the temperature is above the threshold
func _check_vacuum():
	var input_sector_range = 2
	var input = _get_input_pos()
	var input_sector = _get_sector(input.x, input.y)
	var id = 0
	for item in components:
		var com_pos = item[1]
		var input_col = input_sector["column"]
		var input_row = input_sector["row"]
		if input_col >= com_pos["column"] - input_sector_range:
			if input_col <= com_pos["column"] + input_sector_range:
				if input_row >= com_pos["row"] - input_sector_range:
					if input_row <= com_pos["row"] + input_sector_range:
						if matrix[input_row][input_col] > vacuum_remove_threshold:
							print("Remove component" + str(id))
							_destroy_component(id)
							rpc_id(1, "_destroy_component", id)
							if len(components) == 0:
								_game_completed()
								return
						break
		id += 1

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

	var mb = motherboard.rect_size
	dyn_image.create(mb.x, mb.y, false, Image.FORMAT_RGBA8)
	dyn_image.fill(Color(0, 0, 0, 0))
	image_texture.create_from_image(dyn_image)
	image_texture.resource_name = "heatmap"
	var s = Sprite.new()

	s.centered = false
	s.set_texture(image_texture)
	s.modulate.a = 0.7
	s.z_index = 10
	motherboard.add_child(s)

	return s


# Give x and y, get sector of matrix the x and y is found in
# Returns [row, column]
func _get_sector(input_x, input_y):
	var mb_position = motherboard.rect_position
	var mb_size = motherboard.rect_size

	var row_height = mb_size.y / rows
	var column_width = mb_size.x / columns
	var row = floor((input_y - mb_position.y) / row_height)
	var column = floor((input_x - mb_position.x) / column_width)
	return { "row": row, "column": column }

# Generate destroyable components
func _generate_components():
	randomize()
	var yi = 0
	var xi = 0

	var height_padding = 80
	var parts = float(num_of_components) / 2.0 - 1
	
	var pros_sprite = get_node("MotherBoard/processor")
	var pros_pos = pros_sprite.position
	var pros_size = pros_sprite.get_rect().size * pros_sprite.scale

	var seperation_x = pros_size.x + component_width
	var seperation_y = pros_size.y / parts - component_height/ parts - height_padding

	var start_x = pros_pos.x - component_width - pros_size.x / 2
	var start_y = pros_pos.y - pros_size.y / 2 + height_padding

	for _i in range(num_of_components):
		if yi >= num_of_components/2:
			xi += 1
			yi = 0

		var rec = ColorRect.new()
		rec.color = Color(0.4, 0.4, 0.4)

		var x = start_x + xi * seperation_x
		var y = start_y + yi * seperation_y
		rec.set_begin(Vector2(x, y))
		rec.set_end(Vector2(x+ component_width, y + component_height))

		var global_x_center = motherboard.rect_position.x + x + component_width / 2
		var global_y_center =  motherboard.rect_position.y + y + component_height / 2
		components.append([rec, _get_sector(global_x_center, global_y_center)])
		motherboard.add_child(rec)
		yi += 1

remotesync func _destroy_component(id):
	motherboard.remove_child(components[id][0])
	components.remove(id)
	
func _destroy_components():
	components = []
	for x in components:
		motherboard.remove_child(x[0])

func _get_input_pos():
	var cursorpos
	if player_role == Role.DEFUSER:
		cursorpos = pointer_node.position
		rset("puppet_mouse", cursorpos)
	else:
		cursorpos = puppet_mouse
	return cursorpos


func _game_completed():
	rpc("_on_game_completed")


func _game_over():
	rpc("_on_game_over")


remotesync func _soldering_entered():
	if defuse_state == DefuserState.SOLDERING_IRON:
		defuse_state = DefuserState.OFF
		soldering_iron_indicator.color = Color(1, 0, 0)
		iron_label.text = "OFF"
	else:
		if defuse_state == DefuserState.VACUUM:
			vacuum_indicator.color = Color(1, 0, 0)
			vacuum_label.text = "OFF"

		iron_label.text = "ON"
		defuse_state = DefuserState.SOLDERING_IRON
		soldering_iron_indicator.color = Color(0, 1, 0)


remotesync func _vacuum_entered():
	if defuse_state == DefuserState.VACUUM:
		defuse_state = DefuserState.OFF
		vacuum_indicator.color = Color(1, 0, 0)
		vacuum_label.text = "OFF"
	else:
		if defuse_state == DefuserState.SOLDERING_IRON:
			soldering_iron_indicator.color = Color(1, 0, 0)
			iron_label.text = "OFF"

		defuse_state = DefuserState.VACUUM
		vacuum_indicator.color = Color(0, 1, 0)
		vacuum_label.text = "ON"


func _check_input():
	var input = _get_input_pos()
	
	var local_in = soldering_iron_indicator.get_rect()
	var local_bg = $SolderingBackground.get_rect()
	var pos = local_bg.position
	var begin = Vector2(pos.x + local_in.position.x, pos.y + local_in.position.y)
	var end = Vector2(pos.x + local_in.end.x, pos.y + local_in.end.y)
	var sold_rect = Rect2(begin, end)
	 
	if sold_rect.has_point(input):
		if not on_soldering:
			_on_soldering_entered()
			on_soldering = true
	else:
		on_soldering = false
	
	local_in = vacuum_indicator.get_rect()
	local_bg = $VacuumBackground.get_rect()
	pos = local_bg.position
	begin = Vector2(pos.x + local_in.position.x, pos.y + local_in.position.y)
	end = Vector2(pos.x + local_in.end.x, pos.y + local_in.end.y)
	var vacuum_rect = Rect2(begin, end)
	
	if vacuum_rect.has_point(input):
		if not on_vacuum:
			_on_vacuum_entered()
			on_vacuum = true
	else:
		on_vacuum = false


func _on_soldering_entered():
	if player_role == Role.DEFUSER:
		rpc("_soldering_entered")


func _on_vacuum_entered():
	if player_role == Role.DEFUSER:
		rpc("_vacuum_entered")


remotesync func _on_game_completed():
	get_parent().call_deferred("remove_child", self)


remotesync func _on_game_over():
	get_tree().paused = true
