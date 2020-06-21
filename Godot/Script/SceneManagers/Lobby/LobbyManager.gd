extends Control

var voice: Node

onready var player_nodes = [
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player1,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player2,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player3,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player4,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player5
]


func _ready():
	Network.connect("lobby_joined", self, "lobby_joined")
	Network.connect("player_list_changed", self, "refresh_lobby")
	GameState.connect("update_difficulty", self, "update_difficulty")
	GameState.connect("update_team_name", self , "update_team_name")

	var name = Network.player_name + " (You)"
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/You/Label.text = name

	if get_tree().root.has_node("VoiceStream"):
		voice = get_tree().get_root().find_node("VoiceStream", true, false)
		_set_mute_btn(voice.is_recording())
	else:
		Utils.add_scene("res://Scenes/VoiceStream.tscn", get_tree().root)
		voice = get_tree().root.get_node("VoiceStream")
		voice.start()




func lobby_joined(miss_id):
	$MissionID.text = miss_id
	var is_host = Network.host == get_tree().get_network_unique_id()
	$TeamName.editable = is_host
	$DifficultyBtn.disabled = not is_host
	$WaitingForHostLbl.visible = not is_host
	$StartMission.visible = is_host


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


func _on_StartMission_pressed():
	if(!Network.sealed):
		Network.seal_lobby()

	Network.begin_game_pressed()
	get_parent().remove_child(self)


func _on_DifficultyBtn_item_selected(id):
	GameState.difficulty_changed(id)


func _on_MuteBtn_toggled(button_pressed):
	voice.set_recording(button_pressed)


func _set_mute_btn(b : bool):
	$MuteBtn.pressed = b


func update_difficulty(diff):
	$DifficultyBtn.selected = diff


func update_team_name(name):
	$TeamName.text = str(name)


func _on_TeamName_text_changed(new_text):
	GameState.team_name_changed(new_text)


func _on_CancelMission_pressed():
	stop_voip()
	Network.stop()
	return Utils.change_screen("res://Scenes/MainMenu.tscn", self)
