extends Control


func _on_CreateRoomButton_pressed():
	if get_tree().change_scene("res://Scenes/GameRoomHost.tscn") != OK:
		print("Error loading GameRoomHost")


func _on_BackButton_pressed():
	if get_tree().change_scene("res://Scenes/MainMenu.tscn") != OK:
		print("Error loading MainMenu")
