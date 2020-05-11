extends Control


func _on_BackButton_pressed():
	if get_tree().change_scene("res://Scenes/JoinGameRoom.tscn") != OK:
		print("Error loading JoinGameRoom")
