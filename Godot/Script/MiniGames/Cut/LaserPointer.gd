extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var label_disappear_animate = false
var label_disappear_progress = -1.5

func show():
	label_disappear_animate = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if label_disappear_animate:
		self.get_child(0).modulate = Color(1,1,1, min(1, 1.0 - label_disappear_progress))

		label_disappear_progress += .025
		if label_disappear_progress >= 1:
			label_disappear_animate = false
