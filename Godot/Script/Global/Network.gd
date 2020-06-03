extends "../webrtc.gd"

signal player_list_changed()

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 2
const DEFAULT_SERVER = 'wss://signaling-server-bomb.herokuapp.com/'

# Declare member variables here.
var player_name = ""
var player_info = {}
var players_ready = []
var webRTC : WebRTCMultiplayer = WebRTCMultiplayer.new()

# Called when the node enters the scene tree for the first time.
func _init():
	#get_tree().connect("network_peer_connected", self, "_player_connected")
#	connect("lobby_joined", self, "lobby_joined")
#	connect("connected", self, "connected")
#	connect("peer_connected", self, "_player_connected")
#
#	connect("offer_received", self, "offer_received")
#	connect("answer_received", self, "answer_received")
#	connect("candidate_received", self, "candidate_received")
	connect("connected", self, "connected")
	connect("disconnected", self, "disconnected")

	connect("offer_received", self, "offer_received")
	connect("answer_received", self, "answer_received")
	connect("candidate_received", self, "candidate_received")

	connect("lobby_joined", self, "lobby_joined")
	connect("lobby_sealed", self, "lobby_sealed")
	connect("peer_connected", self, "peer_connected")
	connect("peer_disconnected", self, "peer_disconnected")

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")


func create_server(url = DEFAULT_SERVER, port = DEFAULT_PORT, players = MAX_PLAYERS):
	start(url)


func start(url, lobby = ''):
	stop()
	self.lobby = lobby
	connect_to_url(url)

func stop():
	webRTC.close()
	close()

func lobby_joined(lobby):
	print(lobby)
	print(str(get_tree().is_network_server()))

func create_client(lobby, _server_ip = DEFAULT_SERVER, port = DEFAULT_PORT):
	start(_server_ip, lobby)

func connected(id):
	print("Connected %d" % id)
	webRTC.initialize(id, true)
	get_tree().set_network_peer(webRTC)

func peer_connected(id):
	print("Peer connected %d" % id)
	_create_peer(id)
	player_info[id] = str(id)

func _player_connected(id):
	print("We connected player with id: " + str(id))
	player_info[id] = str(id)
	print(get_tree().get_network_connected_peers())
	rpc_id(id, "register_player")


func _create_peer(id):
	var peer : WebRTCPeerConnection = WebRTCPeerConnection.new()
	peer.initialize({
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	})
	peer.connect("session_description_created", self, "_offer_created", [id])
	peer.connect("ice_candidate_created", self, "_new_ice_candidate", [id])
	webRTC.add_peer(peer, id)
	if id > webRTC.get_unique_id():
		peer.create_offer()
	return peer


func _new_ice_candidate(mid_name, index_name, sdp_name, id):
	send_candidate(id, mid_name, index_name, sdp_name)


func _offer_created(type, data, id):
	if not webRTC.has_peer(id):
		return
	print("created", type)
	webRTC.get_peer(id).connection.set_local_description(type, data)
	if type == "offer": send_offer(id, data)
	else: send_answer(id, data)

func _connected_to_server():
	player_name = str(get_tree().get_network_unique_id())


func _connect_fail():
	print("FAILED TO CONNECT")

func offer_received(id, offer):
	print("Got offer: %d" % id)
	if webRTC.has_peer(id):
		webRTC.get_peer(id).connection.set_remote_description("offer", offer)


func answer_received(id, answer):
	print("Got answer: %d" % id)
	if webRTC.has_peer(id):
		webRTC.get_peer(id).connection.set_remote_description("answer", answer)


func candidate_received(id, mid, index, sdp):
	if webRTC.has_peer(id):
		webRTC.get_peer(id).connection.add_ice_candidate(mid, index, sdp)

#### STARTING A GAME

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
