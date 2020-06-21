extends PopupDialog

func _on_Button_pressed():
	hide()

func change_text(string : String):
	$Label.text = string
