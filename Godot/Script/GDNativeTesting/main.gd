extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Sprite_position_changed(node, new_pos):
	print("The position of " + node.name + " is now " + str(new_pos))
