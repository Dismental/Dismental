extends Node2D

var num_of_collectables = 10
var collectables_interval = 2
var collectable_time = 0

var screen_height = 1080
var screen_width = 1920
var kinematic_labels = []

var char_width = 30

var spawn_interval = 2

var rows = 16
var padding_top_bottom = 40

var row_height = (screen_height - 2 * padding_top_bottom) / rows

var moving_speed = 10
var cur_time = 0


func _process(delta):
	_move_labels(delta)
	_spawn_labels(delta)
	_remove_labels()

func _move_labels(delta):
	for s in kinematic_labels:
		s.position.x += char_width * delta * moving_speed

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
				_create_label(pos, _generate_random_char())
				

	
	
func _create_collectable_label(pos, text):
	var kb = _create_label(pos, text)
	kb.get_node("Label").set("custom_colors/font_color", Color(1,0,0))
	var cs = CollisionShape2D.new()
	cs.position = Vector2(15, 30)
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(20, 20)
	cs.shape = shape
	kb.add_child(cs)
	
	
func _create_label(pos, text):
	var s = KinematicBody2D.new()
	s.position = pos
	# s.add_child(particles.instance())
	var label = Label.new()
	label.name = "Label"
	label.text = text
	label.add_font_override("font", load("res://Scenes/Mini Games/Hack/hack_text.tres"))
	label.set("custom_colors/font_color", Color(0,1,0))
	s.add_child(label)
	$LabelSprites.add_child(s)
	kinematic_labels.append(s)
	return s


func _genersate_random_text(min_length, max_length):
	var res = ""
	var num_of_chars = randi() % (max_length - min_length) + min_length
	for _i in range(num_of_chars):
		res += _generate_random_char()
	return res

func _generate_random_char():
	return char(randi() % 100 + 30)

func _remove_labels():
	for i in range(len(kinematic_labels) - 1, -1, -1):
		if kinematic_labels[i].position.x > screen_width + char_width:
			$LabelSprites.remove_child(kinematic_labels[i])
			kinematic_labels.remove(i)
