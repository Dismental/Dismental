extends Label


func _on_HSlider_value_changed(value):
	self.set_text(str(value, "%"))
