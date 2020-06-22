extends Label


func _ready():
	var db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("VoiceChat"))
	self.set_text(str(int(round(db2linear(db) * 100)), "%"))


func _on_HSlider_value_changed(value):
	self.set_text(str(value * 100, "%"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("VoiceChat"), linear2db(value))
