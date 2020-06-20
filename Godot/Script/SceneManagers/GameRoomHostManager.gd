extends Control
var voice: Node

const LOADING_ROOM = "[loading]"
const CONTRACT_REQUIRED = true

var setRoomCode = true
var contractScene
var contract_control
var contract_opened = false

func _init():
	Network.connect("player_list_changed", self, "refresh_lobby")


func _ready():
	refresh_lobby()
	Utils.add_scene("res://Scenes/VoiceStream.tscn", get_parent())
	voice = get_parent().get_node("VoiceStream")
	voice.start()
	
	if CONTRACT_REQUIRED:
		var ContractClass = preload("res://Scenes/Contract.tscn")
		contractScene = ContractClass.instance()
		self.add_child(contractScene)
		contract_control = contractScene.get_node(".")
		contract_opened = true


func _process(_delta):
	if setRoomCode:
		# add the roomcode to a lbl when it is available
		if not Network.gamelobbycode == "":
			get_node("lbl_roomcode_code").text = Network.gamelobbycode
			if CONTRACT_REQUIRED:
				contractScene.get_node("lbl_roomcode").text = "Roomcode: \n " + Network.gamelobbycode
			setRoomCode = false

	if contract_opened and CONTRACT_REQUIRED:
		if contract_control.contract_is_signed:
			self.remove_child(contractScene)
			contract_opened = false
			
	update()

func _on_BackButton_pressed():
	stop_voip()
	Network.stop()
	return Utils.change_screen("res://Scenes/CreateGameRoom.tscn", self)

func _on_StartGameButton_pressed():
	if(!Network.sealed):
		Network.seal_lobby()

	Network.begin_game_pressed()
	get_parent().remove_child(self)

func refresh_lobby():
	var players = Network.get_players().values()
	players.sort()
	$Players/List.clear()
	$Players/List.add_item(Network.player_name + " (You)")
	for p in players:
		$Players/List.add_item(p)

func _on_SealButton_pressed():
	Network.seal_lobby()

func stop_voip():
	voice.stop()
	voice.get_parent().remove_child(voice)
	voice.queue_free()
