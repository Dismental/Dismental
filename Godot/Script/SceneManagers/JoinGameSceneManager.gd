extends Control

func _on_JoinGameButton_pressed():
	_create_client()
	change_scene("res://Scenes/GameRoomPlayer.tscn")

func _on_BackButton_pressed():
	change_scene("res://Scenes/MainMenu.tscn")

func change_scene(filename):
	if get_tree().change_scene(filename) != OK:
		print("Error loading " + str(filename))


func _create_client():
	Network._create_client($InputGameID.text)
