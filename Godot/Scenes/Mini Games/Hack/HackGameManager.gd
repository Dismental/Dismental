extends Node2D

var num_of_collectables = 10
var collectables_interval = 2
var collectable_time = 0
var collectables = []

var screen_height = 1080
var screen_width = 1920
var normal_labels = []

var char_width = 30

var spawn_interval = 2

var rows = 16
var padding_top_bottom = 40

var row_height = (screen_height - 2 * padding_top_bottom) / rows

var moving_speed = 10
var cur_time = 0

onready var bar = $Bar

func _physics_process(delta):
	_move_labels(delta)
	_move_bar()

var fps = 0
func _process(delta):
	_spawn_labels(delta)
	
	fps += 1
	if fps % 20 == 0:
		_remove_labels()

func _move_bar():
	var input = _get_input()
	bar.position.y = input.y

func _get_input():
	return get_viewport().get_mouse_position()

func _move_labels(delta):
	var move_x = char_width * delta * moving_speed
	for s in normal_labels:
		s.position.x += move_x
	
	for c in collectables:
		c.move_and_collide(Vector2(move_x, 0))


func _spawn_labels(delta):
	cur_time += delta
	collectable_time += delta
	
	if cur_time >= (1.0 / moving_speed):
		cur_time = 0
		
		var collectable_index = -1
		
		if collectable_time > collectables_interval:
			collectable_time = 0
			collectables_interval = rand_range(1.5, 6)
			collectable_index = randi() % rows
				
		for i in range(rows):
			var rand = rand_range(0,100)
			if i == collectable_index:
				var pos = Vector2(-char_width, padding_top_bottom + row_height * i)
				_create_collectable_label(pos, _generate_random_char())
				
			elif rand < 15:
				var pos = Vector2(-char_width, padding_top_bottom + row_height * i)
				_create_label_node(pos, _generate_random_char())
				

func _create_collectable_label(pos, text):
	var kb = KinematicBody2D.new()
	kb.position = pos
	
	var label = _create_label(text)
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
	
func _create_label_node(pos, text):
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


func _on_Bar_body_entered(body):
	collectables.remove(collectables.find(body))
	$LabelNodes.remove_child(body)
	print(body)
	

func _on_GameOver_body_entered(body):
	print("game_over")
