extends PopupDialog

# SFX
onready var button_click_sound = $ButtonClick

func _on_Button_pressed():
	button_click_sound.play()
	hide()


func change_text(string : String):
	$Label.text = string
