extends Control

func _on_BackButton_pressed():
	return Utils.change_screen("res://Scenes/CreateGameRoom.tscn",self)


func _on_StartGameButton_pressed():
	Network.begin_game_pressed()
	return Utils.change_screen("res://Scenes/GameScene.tscn", self)

