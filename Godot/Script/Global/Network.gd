extends Node

signal player_list_changed()

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 2

# Declare member variables here.
var player_name = ""
var player_info = {}
var players_ready = []

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")

func create_server(port = DEFAULT_PORT, players = MAX_PLAYERS):
	# Trying to uPnP on the router if not successful the host will only be on
	# the local network
	var upnp = UPNP.new()
	upnp.discover(2000, 2, "InternetGatewayDevice")
	var result = upnp.add_port_mapping(port)
	if (result == 0):
		print("We are accessible from the outside world!")
	else:
		print("We are only accessible from our own local network!")

	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, players)
	get_tree().network_peer = peer
	player_name = "1"
	print("Network created on port: " + str(port))


func create_client(_server_ip, port = DEFAULT_PORT):
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	get_tree().connect("connection_failed", self, "_connect_fail")
	var peer = NetworkedMultiplayerENet.new()
	print("Trying to connect to: " + str(_server_ip))
	peer.create_client(_server_ip, port)
	get_tree().network_peer = peer


func _player_connected(id):
	print("We connected player with id: " + str(id))
	player_info[id] = str(id)
	rpc_id(id, "register_player")


func _connected_to_server():
	player_name = str(get_tree().get_network_unique_id())


func _connect_fail():
	print("FAILED TO CONNECT")


remote func pre_configure_game():
	get_tree().set_pause(true)

	var cut = load("res://Scenes/Mini Games/Cut/Cut.tscn").instance()
	var bombscene = load("res://Scenes/GameScene.tscn").instance()
	get_tree().get_root().add_child(bombscene)

	if not get_tree().is_network_server():
		var self_peer_id = get_tree().get_network_unique_id()
		rpc_id(1, "done_pre_configuring", self_peer_id)


remote func done_pre_configuring(who):
	assert(get_tree().is_network_server())
	assert(who in player_info)
	assert(not who in players_ready)

	players_ready.append(who)

	if players_ready.size() == player_info.size():
		players_ready.clear()
		rpc("begin_game")


remotesync func begin_game():
	get_tree().set_pause(false)


func begin_game_pressed():
	assert(get_tree().is_network_server())

	for p in player_info:
		rpc_id(p, "pre_configure_game")
	pre_configure_game()


remote func pre_configure_minigame(minigame):
	get_tree().set_pause(true)
	print("res://Scenes/Mini Games/%s/%s.tscn" % [minigame, minigame])
	var game = load("res://Scenes/Mini Games/%s/%s.tscn" % [minigame, minigame]).instance()
	get_tree().get_root().add_child(game)

	if not get_tree().is_network_server():
		var self_peer_id = get_tree().get_network_unique_id()
		rpc_id(1, "done_pre_configuring_minigame", self_peer_id)

func start_minigame(minigame):
	assert(get_tree().is_network_server())

	for p in player_info:
		rpc_id(p, "pre_configure_minigame", minigame)
	pre_configure_minigame(minigame)


remote func done_pre_configuring_minigame(who):
	assert(get_tree().is_network_server())
	assert(who in player_info)
	assert(not who in players_ready)

	players_ready.append(who)
	if players_ready.size() == player_info.size():
		players_ready.clear()
		rpc("begin_minigame")


remotesync func begin_minigame():
	get_tree().set_pause(false)


##### Lobby management
remote func register_player():
	var id = get_tree().get_rpc_sender_id()
	player_info[id] = str(id)
	emit_signal("player_list_changed")


func get_players():
	return player_info
