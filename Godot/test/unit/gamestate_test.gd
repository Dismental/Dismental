extends "res://addons/gut/test.gd"


func test_load_roadmap_signal():
	watch_signals(GameState)
	GameState.load_roadmap()
	assert_signal_emitted(GameState, "load_roadmap")


func test_timer_timout_signal():
	watch_signals(GameState)
	GameState._on_timer_timeout()
	assert_signal_emitted(GameState, "timer_timeout")
