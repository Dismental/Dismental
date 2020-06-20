extends MarginContainer

func _on_CreateMissionBtn_pressed():
	if get_input_playername().empty():
		popup("Playername can't be empty!")
	else:
		Network.player_name = get_input_playername()
		Network.create_server()
		return Utils.change_screen("res://Scenes/Lobby/Lobby.tscn", get_parent().get_parent())


func popup(text: String):
	var p_up = get_parent().get_parent().get_node("Popup")
	p_up.change_text(text)
	p_up.popup_centered()


func get_input_playername():
	return $VBoxContainer/PlayerName/Input.text

