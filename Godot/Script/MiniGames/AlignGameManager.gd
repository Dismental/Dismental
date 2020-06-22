extends Control

var debug = false

var running = false

var timer
var timer_wait_time = 60

var rings = []
var controlled_rings = []

# Range for compeltion +- the degree
var completion_range = 30

# Time that is needed to stay on the solution to complete
var completion_delay = 2
var completed_timer = 0

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


# Input behaviour params
var random_input_factor_x
var random_input_factor_y
var random_zero_x
var random_zero_y
var inverted_x
var inverted_y

var rotating = true

var pointer_control
var pointer_node

onready var timer_label = get_node("Timer")

# SFX
onready var game_completed_player = $AudioStreamPlayers/GameCompleted
onready var game_over_player = $AudioStreamPlayers/GameOver

func _ready():
	randomize()
	_adjust_for_difficulties()
	_init_random_input_params()
	_count_num_of_players()
	_set_num_of_rings()

	_init_rings()
	_set_ring_scale()
	_create_timer()

	if debug or get_tree().is_network_server():
		_sync_set_random_angles()
		_assign_random_rings()
		if debug: _start_game()
		else: rpc("_start_game")

	var PointerScene = preload("res://Scenes/Tracking/Pointer.tscn")
	var pointer = PointerScene.instance()
	self.add_child(pointer)
	pointer_control = pointer.get_node(".")
	pointer_control.set_role_and_position(pointer.Role.HEADTHROTTLE, Vector2(0.7,0.5))
	pointer_node = pointer.get_node("Pointer")


func _process(delta):
	if running:
		timer_label.text = str(int(round(timer.get_time_left())))
		_sync_rotate_rings()

		if debug or get_tree().is_network_server():
			if _check_completion():
				if completed_timer > completion_delay:
					if debug: _game_completed()
					else: rpc("_game_completed")
				else:
					completed_timer += delta
			else:
				completed_timer = 0


func _input(_ev):
	if Input.is_key_pressed(KEY_K):
		rotating = !rotating


# Initializes all random parameters for the rotation of the rings
func _init_random_input_params():
	if rand_range(-1, 1) < 0:
		inverted_x = -1
	else:
		inverted_x = 1

	if rand_range(-1, 1) < 0:
		inverted_y = -1
	else:
		inverted_y = 1

	random_input_factor_x = randf() + 1
	random_input_factor_y = randf() + 1
	random_zero_x = (randi() % 100) + 130
	random_zero_y = (randi() % 100) + 130


# Shows the right amount of rings
func _init_rings():
	for i in range(1, 7):
		var node = _get_ring_node(i)
		if i <= num_of_rings:
			rings.append(node)
		else:
			_remove_node(node)


func _adjust_for_difficulties():
	if GameState.difficulty == "EASY":
		timer_wait_time = 30
	elif GameState.difficulty == "MEDIUM":
		timer_wait_time = 25
	elif GameState.difficulty == "HARD":
		timer_wait_time = 20


func _get_ring_node(i):
	return get_node("ring" + str(i))


func _remove_node(node):
	node.visible = false
	call_deferred("remove_child", node)


# Counts the number of peers connected
func _count_num_of_players():
	if debug:
		num_of_players = 1
	else:
		num_of_players = len(get_tree().get_network_connected_peers()) + 1


func _set_num_of_rings():
	num_of_rings = ring_count[num_of_players]


# Calculates the rotation locally and set the ring index and degree to all peers
func _sync_rotate_rings():
	if rotating:
		for ring in controlled_rings:
			var degrees
			var input_pos = _get_input_pos()

			if ring["axis"] == "X":
				input_pos.x = clamp(input_pos.x, 0, get_viewport_rect().size.x)

				var ratio = input_pos.x /  (get_viewport_rect().size.x / random_input_factor_x)
				degrees = inverted_x * fmod(ratio * 360.0 + random_zero_x, 360)

			else:
				input_pos.y = clamp(input_pos.y, 0, get_viewport_rect().size.y)

				var ratio = input_pos.y /  (get_viewport_rect().size.y / random_input_factor_y)
				degrees = inverted_y * fmod(ratio * 360.0 + random_zero_y, 360)

			if degrees < 0:
				degrees += 360

			if debug: _rotate_ring(ring['ringindex'], degrees)
			else: rpc("_rotate_ring", ring['ringindex'], degrees)


# Rotates the ring
remotesync func _rotate_ring(ring_i, degrees):
	var r = rings[ring_i]
	r.rotation_degrees = degrees


# Set the scale of the rings based on the number of rings
func _set_ring_scale():
	var scale = ring_scales[num_of_rings]
	get_node("center").scale = scale
	for x in rings:
		x.scale = scale


# Assigns every player a random ring and an axis of input
# With 2 or 3 players, everyone gets 2 rings.
func _assign_random_rings():
	randomize()

	var options = []
	for x in num_of_rings:
		options.append(x)
	options.shuffle()

	var ring_i = 0

	if not debug:
		var lst = get_tree().get_network_connected_peers()
		if num_of_players >= 4:
			for x in lst:
				var axis = _random_axis()
				rpc_id(x, "_assign_controlled_ring" , options[ring_i], axis)
				ring_i += 1
			controlled_rings.append({"ringindex": options[ring_i], "axis": _random_axis()})
		else:
			for x in lst:
				rpc_id(x, "_assign_controlled_ring", options[ring_i], "X")
				ring_i += 1
				rpc_id(x, "_assign_controlled_ring" , options[ring_i], "Y")
				ring_i += 1
			controlled_rings.append({"ringindex": options[ring_i], "axis": "X"})
			ring_i += 1
			controlled_rings.append({"ringindex": options[ring_i], "axis": "Y"})


# The network server randomly assigns the controlled rings
# and communicates this with this remote function
remote func _assign_controlled_ring(i, axis):
	controlled_rings.append({"ringindex": i, "axis": axis})


# Returns a random axis
func _random_axis():
	if randf() < 0.5:
		return "X"
	return "Y"


# Creates the game timer
func _create_timer():
	timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.set_wait_time(timer_wait_time)
	add_child(timer)
	timer_label.text = str(timer_wait_time)


# Checks if all the rings align with a small error range
func _check_completion():
	for ring in rings:
		var rotation = ring.rotation_degrees
		if not (rotation < completion_range or rotation > 360 - completion_range):
			return false
	return true


# Starts the game and timer
remotesync func _start_game():
	running = true
	timer.start()


# Set every ring to a random starting angle
# Otherwise if no input is detected the rings
# will stay in the right position from the start
func _sync_set_random_angles():
	var lst = []
	for _x in rings:
		lst.append((randi() % (360 - (2 * completion_range))) + completion_range)

	if debug: _set_rings_angle(lst)
	else: rpc("_set_rings_angle", lst)


# Sync start ring angles with all peers
remotesync func _set_rings_angle(lst):
	var i = 0
	for x in lst:
		rings[i].rotation_degrees = x
		i += 1


# Returns the input position
func _get_input_pos():
	return pointer_node.position


# Called when time's up
func _on_timer_timeout():
	_game_over()



remotesync func _game_completed():
	game_completed_player.play()

	$Title.text = "Completed"
	$Title.visible = true

	timer.stop()
	running = false

	GameState.load_roadmap()
	get_parent().call_deferred("remove_child", self)


remotesync func _game_over():
	game_over_player.play()
	yield(get_tree().create_timer(1.0), "timeout")
	get_tree().get_root().get_node("GameScene").game_over()
	get_parent().call_deferred("remove_child", self)
