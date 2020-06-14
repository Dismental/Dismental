extends Control
var voice : Node

func _ready():
	Network.connect("player_list_changed", self, "refresh_lobby")
	refresh_lobby()
	Utils.add_scene("res://Voip/VoiceStream.tscn", get_parent())
	voice = get_parent().get_node("VoiceStream")
	voice.start()


func _on_BackButton_pressed():
	Network.stop()
	return Utils.change_screen("res://Scenes/JoinGameRoom.tscn", self)

func host_disconnect():
	voice.stop()
	voice.get_parent().remove_child(voice)
	voice.queue_free()
	Utils.change_screen("res://Scenes/JoinGameRoom.tscn", self)

func refresh_lobby():
	var players = Network.get_players().values()
	players.sort()
	$Players/List.clear()
	$Players/List.add_item(Network.player_name + " (You)")
	for p in players:
		$Players/List.add_item(p)
