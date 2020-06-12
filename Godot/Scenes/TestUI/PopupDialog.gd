extends PopupDialog


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	show()
	
func show():
	popup_centered_ratio(0.5)
	self.get_child(0).rect_min_size = self.get_rect().size
