extends Control


func _on_BackButton_pressed():
	return Utils.change_screen("res://Scenes/MainMenu.tscn", self)

func _on_TrackingScene_pressed():
	return Utils.change_screen("res://Scenes/DebugTracking.tscn", self)
