extends Node2D

var debug = true

var timer
var timer_wait_time = 10

var rings = []
var controlled_ring_index = 0

# Range for compeltion +- the degree
var completion_range = 30 

# Ring scales depending on the number of rings
var ring_scales= {
	4 : Vector2(0.7, 0.7),
	5 : Vector2(0.6, 0.6),
	6 : Vector2(0.5, 0.5)}

var ring_count = {
			1 : 4, #Debug only
			2 : 4,
			3 : 6,
			4 : 4,
			5 : 5,
			6 : 6}

var num_of_players
var num_of_rings

onready var timer_label = get_node("Timer")



func _ready():
	num_of_players = _count_num_of_players()
	num_of_rings = ring_count[num_of_players]
	for i in range(1, 7):
		var node = get_node("ring" + str(i))
		if i <= num_of_rings:
			rings.append(node)
		else:
			node.visible = false
			call_deferred("remove_child", node)
	_set_ring_scale()
	_create_timer()		
	
	if debug or get_tree().is_network_server():
		_sync_set_random_angles()
		_assign_random_rings()
		_start_game()

func _input(event):
	if debug:
		if event is InputEventKey and event.pressed:
			if event.scancode == KEY_UP:
				 controlled_ring_index += 1
			elif event.scancode == KEY_DOWN:
				controlled_ring_index -= 1

func _process(delta):
	timer_label.text = str(int(round(timer.get_time_left())))
	_input_rotate_rings()
	if debug or get_tree().is_network_server():
		if _check_completion():
			if debug: _game_completed()
			else: rpc("_game_completed")

func _count_num_of_players():
	var num_of_players
	if debug:
		num_of_players = 1
	else:
		num_of_players = len(get_tree().get_network_connected_peers()) + 1
	return num_of_players

func _input_rotate_rings():
	var r = rings[controlled_ring_index]
	var mouse_pos = get_viewport().get_mouse_position()
	var ratio = mouse_pos.x /  get_viewport_rect().size.x 
	var rotation = fmod(ratio * 360.0, 360)
	if rotation < 0:
		rotation += 360
	r.rotation_degrees = rotation

func _set_ring_scale():
	var scale = ring_scales[num_of_rings]
	get_node("center").scale = scale
	for x in rings:
		x.scale = scale

func _assign_random_rings():
	randomize()
	var options = []
	for x in num_of_rings:
		options.append(x)
	options.shuffle()


	
	var random_index = []
	var id = 0
	for x in range(num_of_players):
		random_index.append(options[id])
		id += 1
			

remote func _assign_controlled_ring(i):
	controlled_ring_index = i

func _create_timer():
	timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.set_wait_time(timer_wait_time)
	add_child(timer)
	timer_label.text = str(timer_wait_time)

func _check_completion():
	for ring in rings:
		var rotation = ring.rotation_degrees
		if not (rotation < completion_range or rotation > 360 - completion_range):
			return false
	return true
	
remotesync func _start_game():
	timer.start()
	
func _sync_set_random_angles():
	var lst = []
	for x in range(num_of_rings):
		lst.append(randi() % 360)
	
	if debug: _set_rings_angle(lst)
	else: rpc("_set_rings_angle", lst)

remotesync func _set_rings_angle(lst):
	var i = 0
	for x in lst:
		rings[i].rotation_degrees = x
		i += 1

func _on_timer_timeout():
	if debug:
		_game_over()
	else:
		rpc("_game_over")

remotesync func _game_completed():
	print("Game completed")
	get_parent().remove_child(self)
	
remotesync func _game_over():
	print("Game over")
	get_parent().remove_child(self)
