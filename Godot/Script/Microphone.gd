extends OptionButton

var device_list
var curr_device


# Called when the node enters the scene tree for the first time.
func _ready():
	device_list = AudioServer.capture_get_device_list()
	curr_device = AudioServer.capture_get_device()
	var index = 0
	for device in device_list:
		.add_item(device)
		if device == curr_device:
			self.selected = index
		index += 1

func _on_MicBtn_item_selected(id):
	AudioServer.capture_set_device(device_list[id])
