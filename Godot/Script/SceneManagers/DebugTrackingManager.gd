extends Node2D

var map_sprite
var pointer_node

func _ready():
	print("start tracking scene")
	var pointerScene = preload("res://Scenes/Tracking/Pointer.tscn")
	var pointer = pointerScene.instance()
	self.add_child(pointer)
	var pointer_control = pointer.get_node(".")
	pointer_control.set_role(pointer.ROLE.HEADTHROTTLE)
	pointer_node = pointer.get_node("Pointer")

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
