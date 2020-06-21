extends Label


func _on_HSlider_value_changed(value):
	self.set_text(str(value * 100, "%"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Record"), linear2db(value))
