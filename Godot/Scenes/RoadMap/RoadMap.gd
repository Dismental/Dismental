extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var miniGamePreviews = [
	$CenterContainer/HBoxContainer/Hack,
	$CenterContainer/HBoxContainer/Cut,
	$CenterContainer/HBoxContainer/Align,
	$CenterContainer/HBoxContainer/Dissolve
]
var upcomingMiniGame = 1

var blinkProgress = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(upcomingMiniGame + 1, 4):
		miniGamePreviews[i].modulate = Color(1,1,1,.25)
		
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var upcomingMiniGameNode = miniGamePreviews[upcomingMiniGame]
	var upcomingMiniGameImg = upcomingMiniGameNode.get_node("VBoxContainer/Container/TextureRect")
	var upcomingMiniGameArrow = upcomingMiniGameNode.get_node("VBoxContainer/Arrow")
	
	var alphaVal = 1.0/3 + abs(sin(PI*(blinkProgress))) * (2.0/3)
	upcomingMiniGameImg.modulate = Color(1,1,1, alphaVal)
	upcomingMiniGameArrow.modulate = Color(1,1,1, alphaVal)
	
	blinkProgress = (blinkProgress + .01)
	if blinkProgress >= 1:
		blinkProgress = 0
