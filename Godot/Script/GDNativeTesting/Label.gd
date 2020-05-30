extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().get_node("Button").connect("pressed", self, "_on_button_pressed")

func _on_button_pressed():
	print("The button has been pressed")
