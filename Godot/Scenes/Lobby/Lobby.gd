extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var players = []

onready var playerNodes = [
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player1,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player2,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player3,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player4
]

func add_player(name):
	players.append(name)
	
func remove_player(name):
	if name in players:
		players.remove(name)
	
func refresh():
	for i in range(len(playerNodes)):
		playerNodes[i].visible = false
		
	for i in range(len(players)):
		playerNodes[i].visible = true
		playerNodes[i].get_node("Label").set_text(players[i]) 
	


# Called when the node enters the scene tree for the first time.
func _ready():
	var isHost = false
	
	$TeamNameInput.editable = isHost
	$DifficultyBtn.disabled = not isHost
	$WaitingForHostLbl.visible = not isHost
	$StartMission.visible = isHost
	$CancelMission.visible = isHost
	
	for i in range(len(players)):
		playerNodes[i].visible = true
		playerNodes[i].get_node("Label").set_text(players[i]) 
		
func _process(delta):
	if get_tree().is_network_server():
		if Network.gamelobbycode != "":
			$LineEdit2.text = Network.gamelobbycode
			Network.gamelobbycode = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
