extends "res://addons/gut/test.gd"


func test_on_timer_over():
	var inst = double('res://Script/MiniGames/HackGameManager.gd').new()
	inst.debug = true
	stub(inst, '_on_timer_timeout').to_call_super()

	inst._on_timer_timeout()

	assert_call_count(inst, '_game_over', 1)



