extends Control

func _on_BackButton_pressed():
	Utils._change_screen("res://Scenes/CreateGameRoom.tscn",self)


func _on_StartGameButton_pressed():
	Network._begin_game_pressed()
	Utils._change_screen("res://Scenes/GameScene.tscn", self)


func change_scene(filename):
	if get_tree().change_scene(filename) != OK:
		print("Error loading " + str(filename))
