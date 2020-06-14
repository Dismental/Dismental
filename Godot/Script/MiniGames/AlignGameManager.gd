extends Control

var debug = false

var running = false

var timer
var timer_wait_time = 60

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

var random_input_factor

onready var timer_label = get_node("Timer")


func _ready():
	randomize()
	random_input_factor = randf() + 1

	num_of_players = _count_num_of_players()
	num_of_rings = ring_count[num_of_players]
	_init_rings()
	_set_ring_scale()
	_create_timer()

	if debug or get_tree().is_network_server():
		_sync_set_random_angles()
		_assign_random_rings()
		if debug: _start_game()
		else: rpc("_start_game")

func _input(event):
	if debug:
		if event is InputEventKey and event.pressed:
			if event.scancode == KEY_UP:
				controlled_ring_index += 1
			elif event.scancode == KEY_DOWN:
				controlled_ring_index -= 1

func _process(_delta):
	if running:
		timer_label.text = str(int(round(timer.get_time_left())))
		_sync_rotate_rings()

		if debug or get_tree().is_network_server():
			if _check_completion():
				if debug: _game_completed()
				else: rpc("_game_completed")


func _init_rings():
	for i in range(1, 7):
		var node = get_node("ring" + str(i))
		if i <= num_of_rings:
			rings.append(node)
		else:
			node.visible = false
			call_deferred("remove_child", node)

func _count_num_of_players():
	var num_of_players
	if debug:
		num_of_players = 1
	else:
		num_of_players = len(get_tree().get_network_connected_peers()) + 1
	return num_of_players

func _sync_rotate_rings():
	var input_pos = _get_input_pos()
	if input_pos.x > get_viewport_rect().size.x:
		input_pos.x = get_viewport_rect().size.x
	elif input_pos.x < 0:
		input_pos.x = 0

	var ratio = input_pos.x /  (get_viewport_rect().size.x / random_input_factor)

	var degrees = fmod(ratio * 360.0 + 180, 360)
	if degrees < 0:
		degrees += 360
	if debug: _rotate_ring(controlled_ring_index, degrees)
	else: rpc("_rotate_ring", controlled_ring_index, degrees)

remotesync func _rotate_ring(ring_i, degrees):
	var r = rings[ring_i]
	r.rotation_degrees = degrees

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

	var ring_i = 0

	if not debug:
		var lst = get_tree().get_network_connected_peers()
		for x in lst:
			rpc_id(x, "_assign_controlled_ring" , options[ring_i])
			ring_i += 1
	controlled_ring_index = options[ring_i]

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
	running = true
	timer.start()


func _sync_set_random_angles():
	var lst = []
	for _x in rings:
		lst.append((randi() % 280) + 40)

	if debug: _set_rings_angle(lst)
	else: rpc("_set_rings_angle", lst)


remotesync func _set_rings_angle(lst):
	var i = 0
	for x in lst:
		rings[i].rotation_degrees = x
		i += 1


func _get_input_pos():
	return get_viewport().get_mouse_position()


func _on_timer_timeout():
	if debug:
		_game_over()
	else:
		rpc("_game_over")


remotesync func _game_completed():
	if (debug or get_tree().is_network_server()) and running:
		$AcceptDialog.show()

	$Title.text = "Completed"
	$Title.visible = true

	timer.stop()
	running = false


remotesync func _next_minigame():
	get_parent().remove_child(self)


remotesync func _game_over():
	get_tree().get_root().get_node("GameScene").game_over()
	get_parent().call_deferred("remove_child", self)


func _on_AcceptDialog_confirmed():
	rpc("_next_minigame")
