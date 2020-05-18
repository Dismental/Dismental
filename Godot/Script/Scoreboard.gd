extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_BackButton_pressed():
	change_scene("res://Scenes/MainMenu.tscn")

func change_scene(filename):
	if get_tree().change_scene(filename) != OK:
		print("Error loading " + str(filename))
