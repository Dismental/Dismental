extends Control

func _on_JoinRoomButton_pressed():
	change_scene("res://Scenes/JoinGameRoom.tscn")

func _on_CreateRoomButton_pressed():
	change_scene("res://Scenes/CreateGameRoom.tscn")

func _on_SettingsButton_pressed():
	change_scene("res://Scenes/SettingsScene.tscn")

func _on_ScoreBoardButton_pressed():
	var node = preload("res://Scenes/ScoreScenes/Scoreboard.tscn")
	node = node.instance()
	get_parent().add_child(node)
	get_parent().remove_child(self)
	queue_free()
	if is_queued_for_deletion():
		print("deleting")
	else:
		push_error("can't delete" + str(self))

func change_scene(filename):
	if get_tree().change_scene(filename) != OK:
		print("Error loading " + str(filename))
