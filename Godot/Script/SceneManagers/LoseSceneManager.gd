extends Control


func _on_MainMenuButton_pressed():
	var voice = get_parent().get_node("VoiceStream")
	if (voice != null):
		voice.stop()
		voice.get_parent().remove_child(voice)
		voice.queue_free()
	Network.stop()
	return Utils.change_screen("res://Scenes/MainMenu.tscn", self)
