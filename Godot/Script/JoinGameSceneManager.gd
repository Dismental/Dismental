extends Control

func _on_Join_Game_Button_pressed():
	if get_tree().change_scene("res://Scenes/GameRoomPlayer.tscn") != OK:
		print("Error loading GameRoomPlayer")


func _on_BackButton_pressed():
	if get_tree().change_scene("res://Scenes/MainMenu.tscn") != OK:
		print("Error loading MainMenu")
