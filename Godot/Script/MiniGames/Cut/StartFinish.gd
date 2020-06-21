extends TextureRect

var rotation = 0


func _process(delta):
	rotation += delta * PI / 8
	self.set_rotation(rotation)
