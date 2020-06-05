extends Control

func _ready():
	Network.connect("player_list_changed", self, "refresh_lobby")
	refresh_lobby()


func _on_BackButton_pressed():
	Network.stop()
	return Utils.change_screen("res://Scenes/JoinGameRoom.tscn", self)

func host_disconnect():
	Utils.change_screen("res://Scenes/JoinGameRoom.tscn", self)

func refresh_lobby():
	var players = Network.get_players().values()
	players.sort()
	$Players/List.clear()
	$Players/List.add_item(Network.player_name + " (You)")
	for p in players:
		$Players/List.add_item(p)
