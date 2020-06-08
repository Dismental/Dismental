extends Node2D

var screen_height = 1080
var screen_width = 1920
var label_sprites = []

var char_width = 30

var spawn_interval = 2

var rows = 16
var padding_top_bottom = 40

var row_height = (screen_height - 2 * padding_top_bottom) / rows



var jump_time = 0.1
var cur_time = 0

var particles = preload("res://Scenes/Mini Games/Hack/Particles2D.tscn")


func _process(delta):
	print(Engine.get_frames_per_second())
	for s in label_sprites:
		s.position.x += char_width * delta * (1 / jump_time)
	
	if cur_time >= jump_time:
		cur_time = 0
#			var rand = rand_range(0,100)
#			if rand < 1:
#
#				s.get_node("Label").text = "a"
				
		for i in range(rows):
			var rand = rand_range(0,100)
			if rand < 30:
				_create_label(Vector2(-char_width, padding_top_bottom + row_height * i), _generate_random_char())
	else:
		cur_time += delta
	
	_remove_labels()
		
func _create_label(pos, text):
	var s = Sprite.new()
	s.position = pos
	# s.add_child(particles.instance())
	var label = Label.new()
	label.name = "Label"
	label.text = text
	label.add_font_override("font", load("res://Scenes/Mini Games/Hack/hack_text.tres"))
	label.set("custom_colors/font_color", Color(0,1,0))
	s.add_child(label)
	$LabelSprites.add_child(s)
	label_sprites.append(s)


func _genersate_random_text():
	var res = ""
	for _i in range(randi() % 16 + 4):
		res += _generate_random_char()
	return res

func _generate_random_char():
	return char(randi() % 100 + 30)

func _remove_labels():
	for i in range(len(label_sprites) - 1, -1, -1):
		if label_sprites[i].position.x > screen_width + char_width:
			$LabelSprites.remove_child(label_sprites[i])
			label_sprites.remove(i)
