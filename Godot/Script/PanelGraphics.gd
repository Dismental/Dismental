extends PanelContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
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
