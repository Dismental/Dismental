extends Node2D

var debug = true

var timer
var timer_wait_time = 10

var num_of_rings = 4
var rings = []
var controlled_ring_index = 0

# Range for compeltion +- the degree
var completion_range = 30 

onready var timer_label = get_node("Timer")

func _ready():
	for i in range(1, 7):
		var node = get_node("ring" + str(i))
		if i <= num_of_rings:
			rings.append(node)
		else:
			node.visible = false
			get_parent().call_deferred("remove_child", node)
		
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

func _input_rotate_rings():
	var r = rings[controlled_ring_index]
	var mouse_pos = get_viewport().get_mouse_position()
	var ratio = mouse_pos.x /  get_viewport_rect().size.x 
	var rotation = fmod(ratio * 360.0, 360)
	if rotation < 0:
		rotation += 360
	r.rotation_degrees = rotation

func _assign_random_rings():
	randomize()
	var options = []
	for x in num_of_rings:
		options.append(x)
	options.shuffle()

	var num_of_players = len(get_tree().get_network_connected_peers()) + 1
	
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
