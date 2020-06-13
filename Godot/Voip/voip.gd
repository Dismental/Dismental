extends AudioStreamPlayer

const MIN_PACKET_LENGTH = 0.4

var mic : AudioEffectRecord
var record
var recording = false
var time_elapsed = 0

func _ready():
	mic = AudioServer.get_bus_effect(AudioServer.get_bus_index("Record"), 0)

remote func _play(id, audioPacket : PoolByteArray, format, mix_rate, stereo, size):
	print("received audio from player with id: %s\n" % id)
	var dec = audioPacket.decompress(size, 1)
	var audioStream = AudioStreamSample.new()
	audioStream.data = dec
	audioStream.set_format(format)
	audioStream.set_mix_rate(mix_rate)
	audioStream.set_stereo(stereo)
	stream = audioStream
	play()
	
func _process(delta: float) -> void:
	if recording:
		if mic.is_recording_active():
			if time_elapsed >= MIN_PACKET_LENGTH:
				mic.set_recording_active(false)
				record = mic.get_recording()
				var comp = record.get_data().compress(1)
				rpc_unreliable("_play",get_tree().get_network_unique_id(), comp, record.get_format(), record.get_mix_rate(), record.is_stereo(), record.get_data().size())
				if(comp.size() > 50000):
					print("send recording of size %s\n" % comp.size())
#				print("original size: " + str(record.get_data().size()))
				mic.set_recording_active(true)
				time_elapsed = 0
				
			time_elapsed += delta
		else:
			mic.set_recording_active(true)
	else:
		mic.set_recording_active(false)
		

