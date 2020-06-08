extends Node2D

puppet var puppet_mouse = Vector2()
const Role = preload("res://Script/Role.gd")

var num_of_collectables = 5
var spawned_collectables = 0
var collectables_interval = 2
var collectable_time = 0
var collectables = []
var collected = 0

var normal_labels = []

var screen_height = 1080
var screen_width = 1920
var char_width = 30
var rows = 16
var padding_top_bottom = 40
var row_height = (screen_height - 2 * padding_top_bottom) / rows

var moving_speed = 8
var cur_time = 0

var player_role
var pointer_node

onready var bar = $Bar

func _ready():
	player_role = Role.DEFUSER if get_tree().is_network_server() else Role.SUPERVISOR
	randomize()
	
	if player_role == Role.DEFUSER:
		# Initialize the pointer scene for this user
		var PointerScene = preload("res://Scenes/Tracking/Pointer.tscn")
		var pointer = PointerScene.instance()
		self.add_child(pointer)
		var pointer_control = pointer.get_node(".")
		pointer_control.set_role(pointer.ROLE.HEADTHROTTLE)
		pointer_node = pointer.get_node("Pointer")

func _physics_process(delta):
	_move_labels(delta)
	_move_bar()

var fps = 0
func _process(delta):
	if player_role == Role.DEFUSER:
		_spawn_labels(delta)
	
	fps += 1
	if fps % 20 == 0:
		_remove_labels()

func _move_bar():
	var input = _get_input_pos()
	bar.position.y = input.y

func _move_labels(delta):
	var move_x = char_width * delta * moving_speed
	for s in normal_labels:
		s.translate(Vector2(move_x, 0))
	
	for c in collectables:
		c.move_and_collide(Vector2(move_x, 0))


remotesync func _spawn_labels(delta):
	cur_time += delta
	collectable_time += delta
	
	if cur_time >= (1.0 / moving_speed):
		cur_time = 0
		
		var collectable_index = -1
		
		if collectable_time > collectables_interval and spawned_collectables < num_of_collectables:
			spawned_collectables += 1
			collectable_time = 0
			collectables_interval = rand_range(2, 6)
			collectable_index = randi() % rows
				
		for i in range(rows):
			var rand = rand_range(0,100)
			if i == collectable_index:
				var pos = Vector2(-char_width, padding_top_bottom + row_height * i)
				rpc("_create_collectable_label", pos, _generate_random_char())
				
			elif rand < 15:
				var pos = Vector2(-char_width, padding_top_bottom + row_height * i)
				rpc("_create_label_node", pos, _generate_random_char())


# Creates the chars the user has to collect
remotesync func _create_collectable_label(pos, text):
	var kb = KinematicBody2D.new()
	kb.position = pos
	
	var label = _create_label(text)
	if player_role == Role.SUPERVISOR:
		label.set("custom_colors/font_color", Color(1,0,0))
	kb.add_child(label)
	
	var cs = CollisionShape2D.new()
	cs.position = Vector2(15, 30)
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(20, 20)
	cs.shape = shape
	kb.add_child(cs)
	
	collectables.append(kb)

	$LabelNodes.add_child(kb)

# Creates a normal char without collision detection
remotesync func _create_label_node(pos, text):
	var s = Node2D.new()
	s.position = pos
	s.add_child(_create_label(text))
	$LabelNodes.add_child(s)
	normal_labels.append(s)

# Creates a label with the given text in the coding font style
func _create_label(text):
	var label = Label.new()
	label.name = "Label"
	label.text = text
	label.add_font_override("font", load("res://Scenes/Mini Games/Hack/hack_text.tres"))
	label.set("custom_colors/font_color", Color(0,1,0))
	return label


# Generates a random string
func _genersate_random_text(min_length, max_length):
	var res = ""
	var num_of_chars = randi() % (max_length - min_length) + min_length
	for _i in range(num_of_chars):
		res += _generate_random_char()
	return res

func _generate_random_char():
	return char(randi() % 100 + 30)

# Checks if label is off-screen and removes it if true
func _remove_labels():
	for i in range(len(normal_labels) - 1, -1, -1):
		if normal_labels[i].position.x > screen_width + char_width:
			$LabelNodes.remove_child(normal_labels[i])
			normal_labels.remove(i)

func _get_input_pos():
	var cursorpos
	if player_role == Role.DEFUSER:
		cursorpos = pointer_node.position
		rset("puppet_mouse", cursorpos)
	else:
		cursorpos = puppet_mouse
	return cursorpos
	
# 'Pong' Bar entered
func _on_Bar_body_entered(body):
	if player_role == Role.DEFUSER:
		rpc("_collected_body", collectables.find(body))
		if collected == num_of_collectables:
			rpc("_game_completed")

# Called when a collectable char is collected
remotesync func _collected_body(i):
	collected += 1
	_update_progress_label()
	$LabelNodes.remove_child(collectables[i])
	collectables.remove(i)

# Called when a collectable char hits the offscreen area box
func _on_GameOver_body_entered(body):
	if player_role == Role.DEFUSER:
		rpc("_game_over")
	

func _update_progress_label():
	var percentage_collected = 100 * float(collected) / float(num_of_collectables)
	$ProgressLabel.text = "Progress: " + str(percentage_collected) + "%"
		
remotesync func _game_completed():
	get_parent().remove_child(self)
	

remotesync func _game_over():
	#TODO add gamelogic for gameover
	print("GAME OVER")
	get_parent().remove_child(self)

	
