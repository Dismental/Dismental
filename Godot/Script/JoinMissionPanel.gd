extends MarginContainer


func _on_JoinMissionBtn_pressed():
	if get_input_gameid().empty():
		get_parent().get_parent().popup("Lobby name can't be empty!")
	else:
		if get_input_playername().empty():
			get_parent().get_parent().popup("Playername can't be empty!")
		else:
			Network.player_name = get_input_playername()
			_create_client()
			return Utils.change_screen("res://Scenes/Lobby/Lobby.tscn",
				get_parent().get_parent())


func _create_client():
	Network.create_client(get_input_gameid())


func get_input_gameid():
	return $VBoxContainer/GameID/Input.text


func get_input_playername():
	return $VBoxContainer/PlayerName/Input.text
