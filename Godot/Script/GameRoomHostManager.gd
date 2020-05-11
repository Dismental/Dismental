extends Control

func _on_BackButton_pressed():
	if get_tree().change_scene("res://Scenes/CreateGameRoom.tscn") != OK:
		print("Error loading CreateGameRoom")


func _on_StartGameButton_pressed():
	if get_tree().change_scene("res://Scenes/GameScene.tscn") != OK:
		print("Error loading GameScene")
