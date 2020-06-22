extends "res://addons/gut/test.gd"


func test_load_roadmap_signal():
	watch_signals(GameState)
	GameState.load_roadmap()
	assert_signal_emitted(GameState, "load_roadmap")


func test_timer_timout_signal():
	watch_signals(GameState)
	GameState._on_timer_timeout()
	assert_signal_emitted(GameState, "timer_timeout")


func test_update_team_name():
	watch_signals(GameState)
	assert_eq(GameState.team_name, "BITs")
	GameState.update_team_name("test")
	assert_signal_emitted(GameState, "update_team_name")
	assert_eq(GameState.team_name, "test")


func test_update_difficulty():
	watch_signals(GameState)
	GameState.update_difficulty("EASY")
	GameState.update_difficulty("MEDIUM")
	GameState.update_difficulty("HARD")
	GameState.update_difficulty("INSANE")

	assert_signal_emitted_with_parameters(GameState, "update_difficulty", [0], 0)
	assert_signal_emitted_with_parameters(GameState, "update_difficulty", [1], 1)
	assert_signal_emitted_with_parameters(GameState, "update_difficulty", [2], 2)
	# INSANE difficulty does not exist so no extra signal emit
	assert_signal_emit_count(GameState, "update_difficulty", 3)


func test_update_teamname():
	assert_eq(GameState.team_name, "")
	GameState.update_team_name("test_squad")
	assert_eq(GameState.team_name, "test_squad")
