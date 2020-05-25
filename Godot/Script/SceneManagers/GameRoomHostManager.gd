extends Control

func _on_BackButton_pressed():
	change_scene("res://Scenes/CreateGameRoom.tscn")


func _on_StartGameButton_pressed():
	Network.begin_game_pressed()


func change_scene(filename):
	if get_tree().change_scene(filename) != OK:
		print("Error loading " + str(filename))
