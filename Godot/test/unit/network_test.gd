extends "res://addons/gut/test.gd"

func test_network_signals_connected():
	assert_connected(get_tree(), Network, "network_peer_connected", "_player_connected")
