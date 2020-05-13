extends "res://addons/gut/test.gd"

func test_is_mouse_on_track():
	var inst = double('res://Script/MiniGames/CutDefuser.gd').new()
	stub(inst, '_is_mouse_on_track').to_call_super()
	
	stub(inst, '_get_mouse_pixel_color').to_return(Color(0, 0, 0))
	assert_true(inst._is_mouse_on_track())
	
	stub(inst, '_get_mouse_pixel_color').to_return(Color(0.5, 0.5, 0.5))
	assert_true(inst._is_mouse_on_track())
	
	stub(inst, '_get_mouse_pixel_color').to_return(Color(1, 1, 1))
	assert_false(inst._is_mouse_on_track())

