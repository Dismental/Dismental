extends "res://addons/gut/test.gd"

func test_network_signals_connected():
	assert_connected(Network, Network, "connected", "connected")
	assert_connected(Network, Network, "disconnected", "disconnected")

	assert_connected(Network, Network, "offer_received", "offer_received")
	assert_connected(Network, Network, "answer_received", "answer_received")
	assert_connected(Network, Network, "candidate_received", "candidate_received")

	assert_connected(Network, Network, "lobby_joined", "lobby_joined")
	assert_connected(Network, Network, "lobby_sealed", "lobby_sealed")
	assert_connected(Network, Network, "peer_connected", "peer_connected")
	assert_connected(Network, Network, "peer_disconnected", "peer_disconnected")

	assert_connected(get_tree(), Network, "network_peer_connected", "_player_connected")


func test_network_has_methods():
	assert_has_method(Network, "create_server")
	assert_has_method(Network, "create_client")
	assert_has_method(Network, "start")
	assert_has_method(Network, "stop")
	assert_has_method(Network, "lobby_joined")
	assert_has_method(Network, "lobby_sealed")
	assert_has_method(Network, "connected")
	assert_has_method(Network, "disconnected")
	assert_has_method(Network, "peer_connected")
	assert_has_method(Network, "peer_disconnected")
	assert_has_method(Network, "_player_connected")
	assert_has_method(Network, "add_player_name")
	assert_has_method(Network, "_create_peer")
	assert_has_method(Network, "_new_ice_candidate")
	assert_has_method(Network, "_offer_created")
	assert_has_method(Network, "_connect_fail")
	assert_has_method(Network, "offer_received")
	assert_has_method(Network, "answer_received")
	assert_has_method(Network, "candidate_received")
	assert_has_method(Network, "pre_configure_game")
	assert_has_method(Network, "done_pre_configuring")
	assert_has_method(Network, "begin_game")
	assert_has_method(Network, "begin_game_pressed")
	assert_has_method(Network, "pre_configure_minigame")
	assert_has_method(Network, "start_minigame")
	assert_has_method(Network, "done_pre_configuring_minigame")
	assert_has_method(Network, "begin_minigame")
	assert_has_method(Network, "register_player")
	assert_has_method(Network, "deregister_player")
	assert_has_method(Network, "get_players")
