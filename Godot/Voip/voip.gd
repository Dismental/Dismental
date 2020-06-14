extends AudioStreamPlayer

const MIN_PACKET_LENGTH = 0.2

var mic : AudioEffectRecord
var record
var recording = false
var time_elapsed = 0

func _ready():
	mic = AudioServer.get_bus_effect(AudioServer.get_bus_index("Record"), 1)
	print("voip added")

# Allows for multiple inputs to be played at the same time
func play( from_position=0.0 ):
		if !playing:
			.play(from_position)
		else:
			var audio_player = self.duplicate(DUPLICATE_USE_INSTANCING)
			get_parent().add_child(audio_player)
			audio_player.stream = stream
			audio_player.play()
			yield(audio_player, "finished")
			audio_player.queue_free()

remote func _play(id, audioPacket : PoolByteArray, format, mix_rate, stereo, size):
	if(audioPacket.empty()):
		print("EMPTY AUDIOPACKET")
	else:
		var dec = audioPacket.decompress(size, 1)
		var audioStream = AudioStreamSample.new()
		audioStream.data = dec
		audioStream.set_format(format)
		audioStream.set_mix_rate(mix_rate)
		audioStream.set_stereo(stereo)
		stream = audioStream
		play()

func _helper():
	record = mic.get_recording()
	mic.set_recording_active(true)
	if (record == null):
		print("recording is null!")
	else:
		var comp = record.get_data().compress(1)
		rpc_unreliable("_play",get_tree().get_network_unique_id(), comp, record.get_format(), 
		record.get_mix_rate(), record.is_stereo(), record.get_data().size())
	time_elapsed = 0

func _process(delta: float) -> void:
	if recording:
		if mic.is_recording_active():
			if time_elapsed >= MIN_PACKET_LENGTH:
				mic.set_recording_active(false)
				call_deferred("_helper")
			time_elapsed += delta
		else:
			mic.set_recording_active(true)
	else:
		mic.set_recording_active(false)
		

