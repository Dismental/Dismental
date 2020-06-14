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
	assert_eq(inst.timer.wait_time, inst.timer_wait_time)

	inst._start_game()
	assert_true(inst.running)



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
	assert_eq(sprite1.rotation_degrees, 180)

	inst._rotate_ring(1, 60)
	assert_eq(sprite2.rotation_degrees, 60)
	inst._rotate_ring(1, 0)
	assert_eq(sprite2.rotation_degrees, 0)

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
