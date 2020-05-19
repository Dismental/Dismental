extends Control

func _on_JoinRoomButton_pressed():
	change_scene("res://Scenes/JoinGameRoom.tscn")

func _on_CreateRoomButton_pressed():
	change_scene("res://Scenes/CreateGameRoom.tscn")

func _on_SettingsButton_pressed():
	change_scene("res://Scenes/SettingsScene.tscn")

func _on_ScoreBoardButton_pressed():
	change_scene("res://Scenes/Scoreboard.tscn")

func change_scene(filename):
	if get_tree().change_scene(filename) != OK:
		print("Error loading " + str(filename))


