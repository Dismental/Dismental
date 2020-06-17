extends "res://addons/gut/test.gd"


func test_on_timer_over():
	var inst = double('res://Script/MiniGames/AlignGameManager.gd').new()
	inst.debug = true
	stub(inst, '_on_timer_timeout').to_call_super()

	inst._on_timer_timeout()

	assert_call_count(inst, '_game_over', 1)


func test_timer_creation():
	var inst = load('res://Script/MiniGames/AlignGameManager.gd').new()
	inst.timer_label = Label.new()
	assert_false(inst.running)
	inst._create_timer()
	assert_true(inst.timer.is_stopped())
	assert_eq(int(inst.timer.wait_time), inst.timer_wait_time)
	

func test_generate_starting_angles():
	var inst = load('res://Script/MiniGames/AlignGameManager.gd').new()
	inst.debug = true

	var sprite1 = Sprite.new()
	var sprite2 = Sprite.new()

	inst.rings = [sprite1, sprite2]
	inst._sync_set_random_angles()

	for sprite in inst.rings:
		assert_true(sprite.rotation_degrees > inst.completion_range)
		assert_true(sprite.rotation_degrees < 360 - inst.completion_range)


func test_rotate_rings():
	var inst = load('res://Script/MiniGames/AlignGameManager.gd').new()
	inst.debug = true

	var sprite1 = Sprite.new()
	var sprite2 = Sprite.new()

	inst.rings = [sprite1, sprite2]
	inst._rotate_ring(0, 180)
	assert_eq(sprite1.rotation_degrees, 180.0)

	inst._rotate_ring(1, 60)
	assert_eq(sprite2.rotation_degrees, 60.0)
	inst._rotate_ring(1, 0)
	assert_eq(sprite2.rotation_degrees, 0.0)

func test_num_of_rings():
	var inst = load('res://Script/MiniGames/AlignGameManager.gd').new()

	var players = 2
	inst.num_of_players = players
	inst._set_num_of_rings()
	assert_eq(inst.num_of_rings, inst.ring_count[players])

	players = 5
	inst.num_of_players = players
	inst._set_num_of_rings()
	assert_eq(inst.num_of_rings, inst.ring_count[players])

func test_init_rings():
	var inst = double('res://Script/MiniGames/AlignGameManager.gd').new()

	stub(inst, '_init_rings').to_call_super()
	inst.num_of_rings = 5
	inst._init_rings()

	assert_eq(len(inst.rings), 5)

func test_start_game():
	var inst = partial_double('res://Script/MiniGames/AlignGameManager.gd').new()
	inst.timer = double(Timer).new()
	stub(inst.timer, 'start').to_do_nothing()

	assert_false(inst.running)
	inst._start_game()
	assert_true(inst.running)


func test_init_random_input_params():
	var inst = load('res://Script/MiniGames/AlignGameManager.gd').new()
	randomize()
	for _i in range(4):
		inst._init_random_input_params()
		assert_true(inst.inverted_x in [-1, 1])
		assert_true(inst.inverted_y in [-1, 1])
		assert_between(inst.random_input_factor_x, 1.0, 2.0)
		assert_between(inst.random_input_factor_y, 1.0, 2.0)
		assert_between(inst.random_zero_x, inst.completion_range, 360 - inst.completion_range)
		assert_between(inst.random_zero_y, inst.completion_range, 360 - inst.completion_range)
