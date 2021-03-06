extends Control

var voice: Node

onready var player_nodes = [
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player1,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player2,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player3,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player4,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player5
]

# SFX
onready var button_click_sound = $ButtonClick


func _ready():
	Network.connect("lobby_joined", self, "lobby_joined")
	Network.connect("player_list_changed", self, "refresh_lobby")
	GameState.connect("update_difficulty", self, "update_difficulty")
	GameState.connect("update_team_name", self , "update_team_name")

	var name = Network.player_name + " (You)"
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/You/Label.text = name

	# If we have a network peer already we are in "play again" mode
	if get_tree().has_network_peer():
		_update_ui()
		refresh_lobby()

	if get_tree().root.has_node("VoiceStream"):
		voice = get_tree().get_root().find_node("VoiceStream", true, false)
		_set_mute_btn(voice.is_recording())
	else:
		Utils.add_scene("res://Scenes/VoiceStream.tscn", get_tree().root)
		voice = get_tree().root.get_node("VoiceStream")



func lobby_joined(miss_id):
	$MissionID.text = miss_id
	_update_ui()



func _update_ui():
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
	rpc('GameState.reset_gamestate')
	button_click_sound.play()
	if(Network.player_info.empty()):
		popup("Can't start a game by yourself!")
	else:
		if(!Network.sealed):
			Network.seal_lobby()

		Network.begin_game_pressed()
		rpc("_remove_self")
		get_parent().remove_child(self)
		self.queue_free()


remote func _remove_self():
		get_parent().remove_child(self)
		self.queue_free()


func _on_DifficultyBtn_item_selected(id):
	button_click_sound.play()
	GameState.difficulty_changed(id)


func _on_MuteBtn_toggled(button_pressed):
	button_click_sound.play()
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
	button_click_sound.play()
	stop_voip()
	Network.stop()
	return Utils.change_screen("res://Scenes/MainMenu.tscn", self)


func _on_OpenInstructions_toggled(button_pressed):
	$InstructionsPanel.visible = button_pressed


func _on_ActivatePointer_pressed():
	var PointerScene = preload("res://Scenes/Tracking/Pointer.tscn")
	var pointer = PointerScene.instance()
	self.add_child(pointer)
	var pointer_control = pointer.get_node(".")
	pointer_control.set_role_and_position(pointer.Role.HEADTHROTTLE, Vector2(0.5, 0.55))
	$InstructionsPanel/ActivatePointer.visible = false
	$InstructionsPanel/pointer.visible = true


func _on_CloseInstructions_pressed():
	$InstructionsPanel.visible = false
	$OpenInstructions.pressed = false


func popup(text: String):
	var p_up = $PopupDialog
	p_up.change_text(text)
	p_up.popup_centered()
