extends Control


func _on_JoinGameButton_pressed():
	if get_input_gameid().empty():
		popup("Lobby name can't be empty!")
	else:
		if $PlayerName/Input.text.empty():
		_create_client()
		return Utils.change_screen("res://Scenes/GameRoomPlayer.tscn", self)


func _on_BackButton_pressed():
	return Utils.change_screen("res://Scenes/MainMenu.tscn", self)


func _create_client():
	Network.create_client(get_input_gameid())

func popup(text: String):
	$AcceptDialog.dialog_text = text
	$AcceptDialog.popup_centered()

func get_input_gameid():
	return $InputGameID.text


func _on_Input_text_changed():
	_limit_amount_of_chars()


func _limit_amount_of_chars():
	# Limits the amount of chars that can be entered
	
	var new_text : String = $PlayerName/Input.text
	if new_text.length() > limit:
		$PlayerName/Input.text = current_text
		# when replacing the text, the cursor will get moved to the beginning of the
		# text, so move it back to where it was
		$PlayerName/Input.cursor_set_line(cursor_line)
		$PlayerName/Input.cursor_set_column(cursor_column)

	current_text = $PlayerName/Input.text
	cursor_line = $PlayerName/Input.cursor_get_line()
	cursor_column = $PlayerName/Input.cursor_get_column()
	pass # Replace with function body.


