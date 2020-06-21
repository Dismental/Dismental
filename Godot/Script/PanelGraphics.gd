extends PanelContainer


func _ready():
	update()


func _draw():
	_draw_screws(Rect2(0,0,self.get_rect().size.x,self.get_rect().size.y))



func _draw_screws(rect):
	var screw_radius = 4
	var screw_offset = 16
	var screw_offset_edge = 16
	var x = rect.position.x
	var y = rect.position.y

	# Iterate through every corner
	# Top left
	draw_circle(
		Vector2(x + screw_offset_edge, y + screw_offset_edge),
		screw_radius, Color.black
	)
	draw_circle(
		Vector2(x + screw_offset_edge + screw_offset, y + screw_offset_edge),
		screw_radius, Color.black
	)
	draw_circle(
		Vector2(x + screw_offset_edge, y + screw_offset_edge + screw_offset),
		screw_radius, Color.black
	)

	# Bottom left
	y += rect.size.y
	draw_circle(
		Vector2(x + screw_offset_edge, y - screw_offset_edge),
		screw_radius, Color.black
	)
	draw_circle(
		Vector2(x + screw_offset_edge + screw_offset, y - screw_offset_edge),
		screw_radius, Color.black
	)
	draw_circle(
		Vector2(x + screw_offset_edge, y - screw_offset_edge - screw_offset),
		screw_radius, Color.black
	)

	# Bottom right
	x += rect.size.x
	draw_circle(
		Vector2(x - screw_offset_edge, y - screw_offset_edge),
		screw_radius, Color.black
	)
	draw_circle(
		Vector2(x - screw_offset_edge - screw_offset, y - screw_offset_edge),
		screw_radius, Color.black
	)
	draw_circle(
		Vector2(x - screw_offset_edge, y - screw_offset_edge - screw_offset),
		screw_radius, Color.black
	)

	# Top right
	y -= rect.size.y
	draw_circle(
		Vector2(x - screw_offset_edge, y + screw_offset_edge),
		screw_radius, Color.black
	)
	draw_circle(
		Vector2(x - screw_offset_edge - screw_offset, y + screw_offset_edge),
		screw_radius, Color.black
	)
	draw_circle(
		Vector2(x - screw_offset_edge, y + screw_offset_edge + screw_offset),
		screw_radius, Color.black
	)
