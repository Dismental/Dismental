extends PanelContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():

	update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	update()
	pass
	
func _draw():
	_draw_screws(Rect2(0,0,self.get_rect().size.x,self.get_rect().size.y))
	
func _draw_screws(rect):
	var x = rect.position.x
	var y = rect.position.y
	draw_circle(Vector2(x + 10, y + 10), 2, Color.black)
	draw_circle(Vector2(x + 18, y + 10), 2, Color.black)
	draw_circle(Vector2(x + 10, y + 18), 2, Color.black)
	
	y += rect.size.y
	draw_circle(Vector2(x + 10, y - 10), 2, Color.black)
	draw_circle(Vector2(x + 18, y - 10), 2, Color.black)
	draw_circle(Vector2(x + 10, y - 18), 2, Color.black)
	
	x += rect.size.x
	draw_circle(Vector2(x - 10, y - 10), 2, Color.black)
	draw_circle(Vector2(x - 18, y - 10), 2, Color.black)
	draw_circle(Vector2(x - 10, y - 18), 2, Color.black)
	
	y -= rect.size.y
	draw_circle(Vector2(x - 10, y + 10), 2, Color.black)
	draw_circle(Vector2(x - 18, y + 10), 2, Color.black)
	draw_circle(Vector2(x - 10, y + 18), 2, Color.black)
	
