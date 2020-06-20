extends Control
var voice : Node

var contractScene
var contract_control

const CONTRACT_REQUIRED = true
var contract_opened = false

func _ready():
	Network.connect("player_list_changed", self, "refresh_lobby")
	
	if CONTRACT_REQUIRED:
		var ContractClass = preload("res://Scenes/Contract.tscn")
		contractScene = ContractClass.instance()
		self.add_child(contractScene)
		contract_control = contractScene.get_node(".")
		contract_opened = true
	
	refresh_lobby()
	Utils.add_scene("res://Scenes/VoiceStream.tscn", get_parent())
	voice = get_parent().get_node("VoiceStream")
	voice.start()

func _process(_delta):
	if CONTRACT_REQUIRED:
		if contract_opened and contract_control.contract_is_signed:
			self.remove_child(contractScene)
			contract_opened = false

func _on_BackButton_pressed():
	stop_voip()
	Network.stop()
	return Utils.change_screen("res://Scenes/JoinGameRoom.tscn", self)


func host_disconnect():
	stop_voip()
	Utils.change_screen("res://Scenes/JoinGameRoom.tscn", self)


func refresh_lobby():
	var players = Network.get_players().values()
	players.sort()
	$Players/List.clear()
	$Players/List.add_item(Network.player_name + " (You)")
	for p in players:
		$Players/List.add_item(p)

func stop_voip():
	voice.stop()
	voice.get_parent().remove_child(voice)
	voice.queue_free()
