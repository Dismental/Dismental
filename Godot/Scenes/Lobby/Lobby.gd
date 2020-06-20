extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var players = ["Onno", "Kevin"]

onready var playerNodes = [
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player1,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player2,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player3,
	$PlayersPanel/MarginContainer/VBoxContainer/VBoxContainer/Player4
]

func add_player(name):
	players.append(name)
	
func refresh():
	for i in range(len(playerNodes)):
		playerNodes[i].visible = false
		
	for i in range(len(players)):
		playerNodes[i].visible = true
		playerNodes[i].get_node("Label").set_text(players[i]) 
	


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(len(players)):
		playerNodes[i].visible = true
		playerNodes[i].get_node("Label").set_text(players[i]) 


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
