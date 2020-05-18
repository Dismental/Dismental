extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 2

# Declare member variables here.
var text_label

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")

func _create_server(port = DEFAULT_PORT, players = MAX_PLAYERS):
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
	text_label.set_text("Network created on port: " + str(port))


func _create_client(_server_ip, port = DEFAULT_PORT):
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	get_tree().connect("connection_failed", self, "_connect_fail")
	var peer = NetworkedMultiplayerENet.new()
	text_label.set_text("Trying to connect to: " + str(_server_ip))
	peer.create_client(_server_ip, port)
	get_tree().network_peer = peer


func _player_connected(id):
	text_label.set_text("We connected player with id: " + str(id))
	rpc_id(id, "hello_text", get_tree().get_network_unique_id())


func _connected_to_server():
	pass


func _connect_fail():
	text_label.set_text("FAILED TO CONNECT")


remote func hello_text(id):
	text_label.set_text("We got a hello message from id: " + str(id) + ", we are id: " + str(get_tree().get_network_unique_id()))
