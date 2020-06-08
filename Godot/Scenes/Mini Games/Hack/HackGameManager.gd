extends Node2D

puppet var puppet_mouse = Vector2()

var num_of_collectables = 5
var spawned_collectables = 0
var collectables_interval = 2
var collectable_time = 0
var collectables = []
var collected = 0

var screen_height = 1080
var screen_width = 1920
var normal_labels = []

var char_width = 30

var spawn_interval = 2

var rows = 16
var padding_top_bottom = 40

var row_height = (screen_height - 2 * padding_top_bottom) / rows

var moving_speed = 8
var cur_time = 0

onready var bar = $Bar

const Role = preload("res://Script/Role.gd")

var player_role
var pointer_node

var random_chars = []
var random_char_index = 0

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
#				_create_collectable_label(pos, _generate_random_char())
				rpc("_create_collectable_label", pos, _generate_random_char())
				
			elif rand < 15:
				var pos = Vector2(-char_width, padding_top_bottom + row_height * i)
#				_create_label_node(pos, _generate_random_char())
				rpc("_create_label_node", pos, _generate_random_char())

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
	
remotesync func _create_label_node(pos, text):
	var s = Node2D.new()
	s.position = pos
	s.add_child(_create_label(text))
	$LabelNodes.add_child(s)
	normal_labels.append(s)
	
func _create_label(text):
	var label = Label.new()
	label.name = "Label"
	label.text = text
	label.add_font_override("font", load("res://Scenes/Mini Games/Hack/hack_text.tres"))
	label.set("custom_colors/font_color", Color(0,1,0))
	return label


func _genersate_random_text(min_length, max_length):
	var res = ""
	var num_of_chars = randi() % (max_length - min_length) + min_length
	for _i in range(num_of_chars):
		res += _generate_random_char()
	return res

func _generate_random_char():
	return char(randi() % 100 + 30)

func _remove_labels():
	for i in range(len(normal_labels) - 1, -1, -1):
		if normal_labels[i].position.x > screen_width + char_width:
			$LabelNodes.remove_child(normal_labels[i])
			normal_labels.remove(i)

func _get_input_pos():
#	return get_viewport().get_mouse_position()
	var cursorpos
	if player_role == Role.DEFUSER:
		cursorpos = pointer_node.position
		rset("puppet_mouse", cursorpos)
	else:
		cursorpos = puppet_mouse
	return cursorpos
	

func _on_Bar_body_entered(body):
	if player_role == Role.DEFUSER:
		rpc("_collected_body", collectables.find(body))
		if collected == num_of_collectables:
			rpc("_game_completed")

remotesync func _collected_body(i):
	collected += 1
	$ProgressLabel.text = "Progress: " + str((float(collected ) / float(num_of_collectables)) * 100) + "%"
	$LabelNodes.remove_child(collectables[i])
	collectables.remove(i)

func _on_GameOver_body_entered(body):
	if player_role == Role.DEFUSER:
		rpc("_game_over")
	
remotesync func _game_completed():
	get_parent().remove_child(self)
	
remotesync func _game_over():
	pass
