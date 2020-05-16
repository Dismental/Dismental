extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _input_ip = ''

# Called when the node enters the scene tree for the first time.
func _ready():
	Lobby.text_label = get_node("Label")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_create_server():
	Lobby._create_server()


func _on_create_client_pressed():
	print(_input_ip)
	Lobby._create_client(_input_ip)


func _on_ip_changed(new_text):
	_input_ip = new_text
