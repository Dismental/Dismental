extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var pos = Vector2(0,0)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pos.x = int(pos.x + 1) % 96 - 96
	self.margin_left = pos.x
	self.modulate = Color(1,1,1, 1.0/3 + abs(sin(PI*(pos.x / 96))) / 3)
