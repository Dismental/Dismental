extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var opening_progress = 0

var upcoming_minigame = 1

var blink_progress = 0.0

onready var minigame_previews = [
	$CenterContainer/HBoxContainer/Hack,
	$CenterContainer/HBoxContainer/Cut,
	$CenterContainer/HBoxContainer/Align,
	$CenterContainer/HBoxContainer/Dissolve
]

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(upcoming_minigame + 1, 4):
		minigame_previews[i].modulate = Color(1,1,1,.2)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if opening_progress < 1:
		opening_progress += .01
		$CenterContainer/HBoxContainer.set(
			"custom_constants/separation",
			(1.0 - pow(1.0 - opening_progress, 6)) * 192 - 96
		)

	var upcoming_minigame_node = minigame_previews[upcoming_minigame]
	var upcoming_minigame_img = upcoming_minigame_node.get_node("VBoxContainer/Container/TextureRect")
	var upcoming_minigame_arrow = upcoming_minigame_node.get_node("VBoxContainer/Arrow")

	var alpha_val = 1.0/3 + abs(sin(PI*(blink_progress))) * (2.0/3)
	upcoming_minigame_img.modulate = Color(1,1,1, alpha_val)
	upcoming_minigame_arrow.modulate = Color(1,1,1, alpha_val)

	blink_progress = (blink_progress + .01)
	if blink_progress >= 1:
		blink_progress = 0
