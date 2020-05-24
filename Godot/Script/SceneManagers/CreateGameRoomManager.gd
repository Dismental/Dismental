extends Control

func _on_CreateRoomButton_pressed():
	Network._create_server()
	change_scene("res://Scenes/GameRoomHost.tscn")

func _on_BackButton_pressed():
	change_scene("res://Scenes/MainMenu.tscn")

func change_scene(filename):
	if get_tree().change_scene(filename) != OK:
		print("Error loading " + str(filename))
