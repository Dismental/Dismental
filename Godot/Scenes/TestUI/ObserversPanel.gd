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
	_draw_screws(14,14)
	
func _draw_screws(x,y):
	draw_circle(Vector2(x-4,y-4), 2, Color.black)
	draw_circle(Vector2(x-4,y+4), 2, Color.black)
	draw_circle(Vector2(x+4,y-4), 2, Color.black)
	
