extends Control



func _on_MainMenuButton_pressed():
	Network.stop()
	return Utils.change_screen("res://Scenes/MainMenu.tscn", self)
