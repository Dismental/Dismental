extends Control

func _on_JoinGameButton_pressed():
	_create_client()
	return Utils.change_screen("res://Scenes/GameRoomPlayer.tscn", self)

func _on_BackButton_pressed():
	return Utils.change_screen("res://Scenes/MainMenu.tscn", self)

func _create_client():
	Network.create_client($InputGameID.text)

func host_popup():
	$AcceptDialog.popup_centered()
