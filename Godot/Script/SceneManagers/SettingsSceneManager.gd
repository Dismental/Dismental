extends Control


func _on_BackButton_pressed():
	return Utils.change_screen("res://Scenes/MainMenu.tscn", self)
