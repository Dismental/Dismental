extends Label


func _ready():
	get_parent().get_node("Button").connect("pressed", self, "_on_button_pressed")


func _on_button_pressed():
	print("The button has been pressed")
