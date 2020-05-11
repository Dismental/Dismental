extends Control



func _on_JoinRoomButton_pressed():
	if get_tree().change_scene("res://Scenes/JoinGameRoom.tscn") != OK:
		print("Error loading JoinGameRoom")


func _on_CreateRoomButton_pressed():
	if get_tree().change_scene("res://Scenes/CreateGameRoom.tscn") != OK:
		print("Error loading CreateGameRoom")


func _on_SettingsButton_pressed():
	if get_tree().change_scene("res://Scenes/SettingsScene.tscn") != OK:
		print("Error loading SettingsScene")
