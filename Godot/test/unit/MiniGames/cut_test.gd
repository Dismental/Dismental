extends "res://addons/gut/test.gd"


var inst
const Role = preload("res://Script/Role.gd")

func before_each():
	inst = partial_double('res://Script/MiniGames/Cut/CutGameManager.gd').new()
	

func test_is_input_on_track():
	stub(inst, '_is_input_on_viewport').to_return(true)
	stub(inst, '_get_input_pos').to_return(Vector2(10, 10))
	
	stub(inst, '_get_map_pixel_color').to_return(Color(0, 0, 0, 1))
	assert_true(inst._is_input_on_track())
	
	stub(inst, '_get_map_pixel_color').to_return(Color(0.5, 0.5, 0.5, 0.5))
	assert_true(inst._is_input_on_track())
	
	stub(inst, '_get_map_pixel_color').to_return(Color(1, 1, 1, 0))
	assert_false(inst._is_input_on_track())


func test_update_game_state_nothing():
	inst = double('res://Script/MiniGames/Cut/CutGameManager.gd').new()
	inst.dots = [1, 2, 3]
	inst.player_role = Role.DEFUSER
	
	stub(inst, '_update_game_state').to_call_super()
	stub(inst, '_calc_start_position').to_return(Vector2(0, 0))
	stub(inst, '_is_input_on_track').to_return(true)
	stub(inst, '_get_input_pos').to_return(Vector2(200, 200))
	
	inst._update_game_state()
	
	assert_call_count(inst, '_game_over', 0)
	assert_call_count(inst, '_game_completed', 0)

func test_update_game_state_game_over():
	inst = double('res://Script/MiniGames/Cut/CutGameManager.gd').new()
	inst.dots = [1, 2, 3]
	inst.player_role = Role.DEFUSER

	stub(inst, '_calc_start_position').to_return(Vector2(0, 0))
	stub(inst, '_update_game_state').to_call_super()
	stub(inst, '_is_input_on_track').to_return(false)
	stub(inst, '_game_over').to_do_nothing()
	inst.waitForStartingPosition = false
	inst._update_game_state()

	assert_call_count(inst, '_game_over', 1)
	assert_call_count(inst, '_game_completed', 0)
	

func test_update_game_state_game_completed_clockwise():
	inst.dots = [Vector2(0, 0), Vector2(0, 0), Vector2(0, 3)]
	inst.finish_state = 1
	inst.finish_rect = Rect2(0, 0, 2, 2)
	inst.player_role = Role.DEFUSER

	stub(inst, '_is_input_on_track').to_return(true)
	stub(inst, '_get_input_pos').to_return(Vector2(1, 1))
	stub(inst, '_game_completed').to_do_nothing()
	inst.waitForStartingPosition = false
	inst._update_game_state()
	
	assert_call_count(inst, '_game_over', 0)
	assert_call_count(inst, '_game_completed', 1)
	
func test_update_game_state_game_completed_counterclockwise():
	inst.dots = [Vector2(0, 0), Vector2(0, 0), Vector2(0, -1)]
	inst.finish_state = -1
	inst.finish_rect = Rect2(0, 0, 2, 2)
	inst.player_role = Role.DEFUSER

	stub(inst, '_is_input_on_track').to_return(true)
	stub(inst, '_get_input_pos').to_return(Vector2(1, 1))
	stub(inst, '_game_completed').to_do_nothing()
	inst.waitForStartingPosition = false
	
	inst._update_game_state()
	
	assert_call_count(inst, '_game_over', 0)
	assert_call_count(inst, '_game_completed', 1)
	
func test_update_game_state_finish_logic_clockwise():
	inst.finish_state = 0
	inst.finish_rect = Rect2(0, 0, 2, 2)
	
	stub(inst, '_get_input_pos').to_return(Vector2(0, -1))
	inst.waitForStartingPosition = false
	inst._check_finish()
	
	assert_call_count(inst, '_game_over', 0)
	assert_call_count(inst, '_game_completed', 0)
	assert_true(inst.finish_state == 1)
	
	
func test_update_game_state_finish_logic_counterclockwise():
	inst.finish_state = 0
	inst.finish_rect = Rect2(0, 0, 2, 2)
	
	stub(inst, '_get_input_pos').to_return(Vector2(0, 3))
	inst.waitForStartingPosition = false
	inst._check_finish()
	
	assert_call_count(inst, '_game_over', 0)
	assert_call_count(inst, '_game_completed', 0)
	assert_true(inst.finish_state == -1)
