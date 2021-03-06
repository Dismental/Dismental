extends "../webrtc.gd"

signal player_list_changed()
signal player_disconnected()

const DEFAULT_SERVER = 'wss://signaling-server-bomb.herokuapp.com/'

export var gamelobbycode = ""

var host = 1
var player_name = ""
var player_info = {}
var players_ready = []
var web_rtc : WebRTCMultiplayer = WebRTCMultiplayer.new()
var sealed = false


# Called when the node enters the scene tree for the first time.
func _init():
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
	get_tree().connect("network_peer_disconnected", self, "peer_disconnected")


func create_server(url = DEFAULT_SERVER):
	start(url)


func create_client(lobby, _server_ip = DEFAULT_SERVER):
	start(_server_ip, lobby)


func start(url, lobby = ''):
	stop()
	sealed = false
	self.lobby = lobby
	connect_to_url(url)


func stop():
	player_info.clear()
	web_rtc.close()
	close()
	get_tree().set_network_peer(null)
	web_rtc = WebRTCMultiplayer.new()


func lobby_joined(lobby):
	gamelobbycode = lobby
	print(lobby)


func lobby_sealed():
	print("lobby was sealed")
	sealed = true


func connected(id):
	print("Connected %d" % id)
	web_rtc.initialize(id, true)
	get_tree().set_network_peer(web_rtc)


func disconnected():
	print("Disconnected: %d: %s" % [code, reason])

	if code == 4100:
		print("host disconnect")
		if get_tree().get_root().has_node("VoiceStream"):
			var voice = get_tree().get_root().get_node("VoiceStream")
			voice.stop()
			voice.get_parent().remove_child(voice)
			voice.queue_free()

		var curr_node
		if GameState.running:
			curr_node = get_tree().get_root().get_node("GameScene")
			GameState.reset_gamestate()

		else:
			curr_node = get_tree().get_root().find_node("Lobby", true, false)

		stop()
		var succes = Utils.change_screen("res://Scenes/MainMenu.tscn", curr_node)
		get_tree().get_root().find_node("MainMenu", true, false).popup(
			"Host disconnected")
		return succes

	elif code == 4004:
		var curr_node = get_tree().get_current_scene().get_node("Lobby")
		curr_node.stop_voip()
		stop()
		Utils.change_screen("res://Scenes/MainMenu.tscn", curr_node)
		get_tree().get_current_scene().get_node("MainMenu").popup(
			"Room with that name does not exist")

	elif code == 4444:
		var curr_node = get_tree().get_current_scene().get_node("Lobby")
		curr_node.stop_voip()
		stop()
		Utils.change_screen("res://Scenes/MainMenu.tscn", curr_node)
		get_tree().get_current_scene().get_node("MainMenu").popup(
			"That room is currently full!")

	elif not sealed:
		stop() #Unexpected disconnect


func peer_connected(id):
	print("Peer connected %d" % id)
	_create_peer(id)


func peer_disconnected(id):
	if web_rtc.has_peer(id):
		print("removing peer")
		web_rtc.remove_peer(id)
	if player_info.has(id):
		emit_signal("player_disconnected", id, player_info[id])
	deregister_player(id)


func _player_connected(id):
	print("We connected player with id: " + str(id))
	print(get_tree().get_network_connected_peers())
	rpc_id(id, "register_player", player_name)
	if get_tree().get_network_unique_id() == host:
		GameState.init_lobby_options(id)
	emit_signal("player_list_changed")


remote func add_player_name(name: String):
	var id = get_tree().get_rpc_sender_id()
	player_info[id] = name


func _create_peer(id):
	var peer : WebRTCPeerConnection = WebRTCPeerConnection.new()
	peer.initialize({
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	})
	peer.connect("session_description_created", self, "_offer_created", [id])
	peer.connect("ice_candidate_created", self, "_new_ice_candidate", [id])
	web_rtc.add_peer(peer, id)
	if id > web_rtc.get_unique_id():
		peer.create_offer()
	return peer


func _new_ice_candidate(mid_name, index_name, sdp_name, id):
	send_candidate(id, mid_name, index_name, sdp_name)


func _offer_created(type, data, id):
	if not web_rtc.has_peer(id):
		return
	print("created", type)
	web_rtc.get_peer(id).connection.set_local_description(type, data)
	if type == "offer": send_offer(id, data)
	else: send_answer(id, data)


func _connect_fail():
	print("FAILED TO CONNECT")


func offer_received(id, offer):
	print("Got offer: %d" % id)
	if web_rtc.has_peer(id):
		web_rtc.get_peer(id).connection.set_remote_description("offer", offer)


func answer_received(id, answer):
	print("Got answer: %d" % id)
	if web_rtc.has_peer(id):
		web_rtc.get_peer(id).connection.set_remote_description("answer", answer)


func candidate_received(id, mid, index, sdp):
	if web_rtc.has_peer(id):
		web_rtc.get_peer(id).connection.add_ice_candidate(mid, index, sdp)


#### STARTING A GAME
remote func pre_configure_game():
	get_tree().set_pause(true)

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
	if GameState.defusers[GameState.minigame_index] != -1:
		var defuser_id = GameState.defusers[GameState.minigame_index]
		game.set_network_master(defuser_id)

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
remote func register_player(name):
	var id = get_tree().get_rpc_sender_id()
	player_info[id] = name
	emit_signal("player_list_changed")


func deregister_player(id):
	if player_info.has(id):
		player_info.erase(id)
		print("removing player: " + str(id))
		emit_signal("player_list_changed")


func get_players():
	return player_info

func clear_ready_players():
	players_ready.clear()
