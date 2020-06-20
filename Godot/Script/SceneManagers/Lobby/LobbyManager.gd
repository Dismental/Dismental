extends Control

onready var player_nodes = [
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player1,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player2,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player3,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player4
]

var voice: Node

func _ready():
	Network.connect("lobby_joined", self, "lobby_joined")
	Network.connect("player_list_changed", self, "refresh_lobby")
	
	var name = Network.player_name + " (You)"
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/You/Label.text = name
	
	Utils.add_scene("res://Scenes/VoiceStream.tscn", get_parent())
	voice = get_parent().get_node("VoiceStream")
	voice.start()

func lobby_joined(miss_id):
	$MissionID.text = miss_id
	var is_host = Network.host == get_tree().get_network_unique_id()
	$TeamNameInput.editable = is_host
	$DifficultyBtn.disabled = not is_host
	$WaitingForHostLbl.visible = not is_host
	$StartMission.visible = is_host
	$CancelMission.visible = is_host


func stop_voip():
	voice.stop()
	voice.get_parent().remove_child(voice)
	voice.queue_free()


func refresh_lobby():
	var players = Network.get_players().values()
	players.sort()
	
	for i in range(len(player_nodes)):
		player_nodes[i].visible = false

	for i in range(len(players)):
		player_nodes[i].visible = true
		player_nodes[i].get_node("Label").set_text(players[i])
