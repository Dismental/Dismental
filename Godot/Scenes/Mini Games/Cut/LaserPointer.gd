extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var labelDisappearAnimate = false
var labelDisappearProgress = -1.5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func show():
	labelDisappearAnimate = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if labelDisappearAnimate:
		self.get_child(0).modulate = Color(1,1,1, min(1, 1.0 - labelDisappearProgress))
		
		labelDisappearProgress += .025
		if labelDisappearProgress >= 1: 
			labelDisappearAnimate = false
