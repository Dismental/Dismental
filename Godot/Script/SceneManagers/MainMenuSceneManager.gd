extends Control


func _on_JoinRoomButton_pressed():
	return Utils.change_screen("res://Scenes/JoinGameRoom.tscn", self)


func _on_CreateRoomButton_pressed():
	return Utils.change_screen("res://Scenes/CreateGameRoom.tscn", self)


func _on_SettingsButton_pressed():
	return Utils.change_screen("res://Scenes/SettingsScene.tscn", self)


func _on_ScoreBoardButton_pressed():
	return Utils.change_screen("res://Scenes/ScoreScenes/Scoreboard.tscn", self)
