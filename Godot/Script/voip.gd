extends Node

const MIN_PACKET_LENGTH = 0.2

var mic : AudioEffectRecord
var record
var recording = false
var time_elapsed = 0
var mute_players : Dictionary

func _ready():
	mic = AudioServer.get_bus_effect(AudioServer.get_bus_index("Record"), 1)

# Allows for playing of audiopackets of multiple players at the same time
func custom_play(id : int, audio_stream):
	var index = Network.player_info.keys().find(id)
	match index:
		0:
			$Player.stream = audio_stream
			$Player.play()
		1:
			$Player1.stream = audio_stream
			$Player1.play()
		2:
			$Player2.stream = audio_stream
			$Player2.play()
		3:
			$Player3.stream = audio_stream
			$Playe3.play()
		4:
			$Player4.stream = audio_stream
			$Player4.play()
		_:
			print("index not found!")


remote func _play(id, audiopacket : PoolByteArray, format, mix_rate, stereo):
	if(audiopacket.empty()):
		print("EMPTY AUDIOPACKET")
	else:
		if(mute_players.has(id)):
			return
		var audio_stream = AudioStreamSample.new()
		audio_stream.data = audiopacket
		audio_stream.set_format(format)
		audio_stream.set_mix_rate(mix_rate)
		audio_stream.set_stereo(stereo)
		custom_play(id, audio_stream)


func _helper():
	record = mic.get_recording()
	mic.set_recording_active(true)
	if (record == null):
		print("recording is null!")
	else:
		rpc("_play",get_tree().get_network_unique_id(), record.get_data(), record.get_format(),
		record.get_mix_rate(), record.is_stereo())
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

