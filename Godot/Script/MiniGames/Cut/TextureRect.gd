extends TextureRect


var pos = Vector2(0,0)


func _process(_delta):
	pos.x = int(pos.x + 1) % 96 - 96
	self.margin_left = pos.x
	self.modulate = Color(1,1,1, 1.0/3 + abs(sin(PI*(pos.x / 96))) / 3)
