extends Node2D

var map_sprite
var pointer_node
var tracking_control


enum ROLEP{
	NOTSET,
	HEAD,
	HAND,
	MOUSE,
	DEBUG
}


func _ready():
	print("start tracking scene")
	var TrackingScene = preload("res://Scenes/Tracking/Tracking.tscn")
	var tracking = TrackingScene.instance()
	self.add_child(tracking)
	tracking_control = tracking.get_node(".")
	tracking_control.set_role(ROLEP.DEBUG)
	pointer_node = tracking.get_node("Pointer")


func _process(_delta):
	# Updates the draw function
	update()

func _draw():
	# Get cursor position
	var input_pos = pointer_node.position

	# Draw current pointer at cursor position
	var rad = 25
	var col = Color(0, 1, 0)
	draw_circle(input_pos, rad, col)

func _unhandled_input(event):
	# Quit the game when escape is pressed
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			# Quits the game
			get_tree().quit()
