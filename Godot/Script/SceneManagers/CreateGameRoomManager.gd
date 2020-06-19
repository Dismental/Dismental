extends Control


func _on_CreateRoomButton_pressed():
		Network.player_name = current_text
	Network.create_server()
	return Utils.change_screen("res://Scenes/GameRoomHost.tscn", self)


func _on_BackButton_pressed():
	return Utils.change_screen("res://Scenes/MainMenu.tscn", self)


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
