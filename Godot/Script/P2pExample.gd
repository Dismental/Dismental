extends Control

# Declare member variables here. Examples:
var _input_ip = ''


# Called when the node enters the scene tree for the first time.
func _ready():
	Network.text_label = get_node("Label")


func _on_create_server():
	Network._create_server()


func _on_create_client_pressed():
	print(_input_ip)
	Network._create_client(_input_ip)


func _on_ip_changed(new_text):
	_input_ip = new_text
