extends Control

func _on_CreateRoomButton_pressed():
	Network.create_server()
	return Utils._change_screen("res://Scenes/GameRoomHost.tscn", self)

func _on_BackButton_pressed():
	return Utils._change_screen("res://Scenes/MainMenu.tscn", self)

func change_scene(filename):
	if get_tree().change_scene(filename) != OK:
		print("Error loading " + str(filename))
