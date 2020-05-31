extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 2

# Declare member variables here.
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
	player_info[id] = "" # Empty details of the player for now


func _connected_to_server():
	pass


func _connect_fail():
	print("FAILED TO CONNECT")


remote func hello_text(id):
	var self_id = get_tree().get_network_unique_id()
	print("We got a hello message from id: " + str(id) + ", we are id: " + str(self_id))


remote func pre_configure_game():
	get_tree().set_pause(true)
	var self_peer_id = get_tree().get_network_unique_id()

	var cut = load("res://Scenes/Mini Games/Cut/Cut.tscn").instance()
	get_tree().get_root().add_child(cut)

	if not get_tree().is_network_server():
		rpc_id(1, "done_pre_configuring", self_peer_id)


remote func done_pre_configuring(who):
	assert(get_tree().is_network_server())
	assert(who in player_info)
	assert(not who in players_ready)

	players_ready.append(who)

	if players_ready.size() == player_info.size():
		rpc("begin_game")


remotesync func begin_game():
	get_tree().set_pause(false)


func begin_game_pressed():
	assert(get_tree().is_network_server())

	for p in player_info:
		rpc_id(p, "pre_configure_game")
	pre_configure_game()
