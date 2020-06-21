extends MarginContainer

func _on_CreateMissionBtn_pressed():
	if get_input_playername().empty():
		get_parent().get_parent().popup("Playername can't be empty!")
	else:
		Network.player_name = get_input_playername()
		Network.create_server()
		return Utils.change_screen("res://Scenes/Lobby/Lobby.tscn", get_parent().get_parent())


func get_input_playername():
	return $VBoxContainer/PlayerName/Input.text

