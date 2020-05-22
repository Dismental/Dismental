extends Control

func _on_JoinRoomButton_pressed():
	Utils._change_screen("res://Scenes/JoinGameRoom.tscn", self)

func _on_CreateRoomButton_pressed():
	Utils._change_screen("res://Scenes/CreateGameRoom.tscn", self)	

func _on_SettingsButton_pressed():
	Utils._change_screen("res://Scenes/SettingsScene.tscn", self)

func _on_ScoreBoardButton_pressed():
	Utils._change_screen("res://Scenes/ScoreScenes/Scoreboard.tscn", self)


func change_scene(filename):
	if get_tree().change_scene(filename) != OK:
		print("Error loading " + str(filename))
