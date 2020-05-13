extends "res://addons/gut/test.gd"


func test_is_mouse_on_track():
	var inst = partial_double('res://Script/MiniGames/CutDefuser.gd').new()
	
	stub(inst, '_get_mouse_pixel_color').to_return(Color(0, 0, 0))
	assert_true(inst._is_mouse_on_track())
	
	stub(inst, '_get_mouse_pixel_color').to_return(Color(0.5, 0.5, 0.5))
	assert_true(inst._is_mouse_on_track())
	
	stub(inst, '_get_mouse_pixel_color').to_return(Color(1, 1, 1))
	assert_false(inst._is_mouse_on_track())

func test_file_count_in_this_directory():
	var script = load('res://Script/MiniGames/CutDefuser.gd').new()
	assert(script._count_files_in_dir("res://test/unit/MiniGames/") > 0)

func test_update_game_state_nothing():
	var inst = double('res://Script/MiniGames/CutDefuser.gd').new()
	stub(inst, '_update_game_state').to_call_super()
	
	stub(inst, '_is_mouse_on_track').to_return(true)
	stub(inst, '_get_mouse_pos').to_return(Vector2(200, 200))
	inst._update_game_state()
	assert_call_count(inst, '_game_over', 0)
	assert_call_count(inst, '_game_completed', 0)

func test_update_game_state_game_over():
	var inst = double('res://Script/MiniGames/CutDefuser.gd').new()
	stub(inst, '_update_game_state').to_call_super()
	
	stub(inst, '_is_mouse_on_track').to_return(false)
	inst._update_game_state()
	assert_call_count(inst, '_game_over', 1)
	assert_call_count(inst, '_game_completed', 0)
	

func test_update_game_state_game_completed():
	var inst = double('res://Script/MiniGames/CutDefuser.gd').new()
	stub(inst, '_update_game_state').to_call_super()
	stub(inst, '_is_mouse_on_track').to_return(true)
	stub(inst, '_get_mouse_pos').to_return(Vector2(1910, 200))
	inst._update_game_state()
	assert_call_count(inst, '_game_over', 0)
	assert_call_count(inst, '_game_completed', 1)
	
