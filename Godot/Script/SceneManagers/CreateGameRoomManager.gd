extends Control

func _on_CreateRoomButton_pressed():
	Network.create_server()
	return Utils.change_screen("res://Scenes/GameRoomHost.tscn", self)

func _on_BackButton_pressed():
	return Utils.change_screen("res://Scenes/MainMenu.tscn", self)
