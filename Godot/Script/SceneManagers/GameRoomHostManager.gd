extends Control
func _init():
	Network.connect("player_list_changed", self, "refresh_lobby")

func _ready():
	refresh_lobby()

func _on_BackButton_pressed():
	Network.stop()
	return Utils.change_screen("res://Scenes/CreateGameRoom.tscn", self)


func _on_StartGameButton_pressed():
	if(!Network.sealed):
		Network.seal_lobby()
	Network.begin_game_pressed()
	get_parent().remove_child(self)


# TODO: Remove GameRoomPlayer from all peers
#	print(get_tree().get_network_connected_peers())
#	for peer in get_tree().get_network_connected_peers():
#		rpc_id(peer, "_remove_room_scene")
#
#remote func _remove_room_scene():
#	get_tree().get_root().remove_child(get_node("Main/GameRoomPlayer"))

func refresh_lobby():
	var players = Network.get_players().values()
	players.sort()
	$Players/List.clear()
	$Players/List.add_item(Network.player_name + " (You)")
	for p in players:
		$Players/List.add_item(p)


func _on_SealButton_pressed():
	Network.seal_lobby()
