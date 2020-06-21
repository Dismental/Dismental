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
