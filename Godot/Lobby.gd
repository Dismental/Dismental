extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 2

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var players = { }
var self_data = { name: '' }
var _last_text = ''
var text_label

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	print("Lobby was loaded")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_create_server_pressed():
	self_data.name = "SERVER"
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	text_label.set_text("Network created on port: " + str(DEFAULT_PORT))


func _on_create_client_pressed(_server_ip):
	self_data.name = "CLIENT"
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	get_tree().connect("connection_failed", self, "_connected_fail")
	var peer = NetworkedMultiplayerENet.new()
	text_label.set_text("Trying to connect to: " + str(_server_ip))
	peer.create_client(_server_ip, DEFAULT_PORT)
	get_tree().network_peer = peer


func _player_connected(id):
	print(get_tree().get_network_unique_id())
	text_label.set_text("We connected player with id: " + str(id))
	rpc_id(id, "hello_text", get_tree().get_network_unique_id())


func _connected_to_server():
	pass # _last_text = "CONNECTED TO SERVER"


func _connect_fail():
	text_label.set_text("FAILED TO CONNECT")


remote func hello_text(id):
	text_label.set_text("We got a hello message from id: " + str(id) + ", we are id: " + str(get_tree().get_network_unique_id()))
