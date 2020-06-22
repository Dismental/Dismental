extends Control

var explosion_animate = true
var explosion_progress = 0

onready var explosion_movement = $ExplodeLabel.get_rect().size.x + self.get_rect().size.x
onready var button_click_sound = $ButtonClick


func _ready():
	$ExplodeBackground.visible = true
	$ExplodeLabel.visible = true

	$Squad.text = $Squad.text + GameState.team_name
	for player in Network.player_info.values():
		$Squad/Members.add_item(player)

func _process(_delta):
	if explosion_progress < 1:
		explosion_progress += _delta * .33
		var explosion_pos = pow(explosion_progress, 2)
		$ExplodeLabel.margin_left = -explosion_movement * explosion_pos * 2
	else:
		$ExplodeBackground.visible = false
		$ExplodeLabel.visible = false

func _on_MainMenuButton_pressed():
	button_click_sound.play()
	if get_parent().has_node("VoiceStream"):
		var voice = get_parent().get_node("VoiceStream")
		voice.stop()
		voice.get_parent().remove_child(voice)
		voice.queue_free()
	Network.stop()
	return Utils.change_screen("res://Scenes/MainMenu.tscn", self)


func _on_ScoreBoardButton_pressed():
	button_click_sound.play()
	return Utils.add_scene("res://Scenes/ScoreScenes/Scoreboard.tscn", self)
