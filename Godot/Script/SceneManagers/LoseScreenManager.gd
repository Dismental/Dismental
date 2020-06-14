extends Control



func _on_MainMenuButton_pressed():
	return Utils.change_screen("res://Scenes/MainMenu.tscn", self)
