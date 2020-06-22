extends Control

var success_animate = true
var success_progress = 0

onready var button_click_sound = $ButtonClick


func _ready():
	$SuccessBackground.visible = true
	$SuccessLabel.visible = true

	$PlayAgainButton.disabled = get_tree().get_network_unique_id() != Network.host

	var score : Score = ScoreManager.get_scores().back()
	ScoreManager.sort_scores()
	var score_pos = ScoreManager.get_scores().find(score) + 1
	$Squad.text = GameState.team_name
	$Squad/Members.add_item(Network.player_name)
	for player in Network.player_info.values():
		$Squad/Members.add_item(player)
	$Squad/Score.text += "\n" + str(score.get_time()) + "\n"
	match score_pos:
		1:
			$Squad/Score.text +=  str(score_pos)  + "st on scoreboard"
		2:
			$Squad/Score.text +=  str(score_pos)  + "nd on scoreboard"
		3:
			$Squad/Score.text +=  str(score_pos)  + "rd on scoreboard"
		_:
			$Squad/Score.text +=  str(score_pos)  + "th on scoreboard"

func _process(_delta):
	if success_progress < 1:
		success_progress += _delta * .5
		var explosion_pos = pow(success_progress, 2)
		$SuccessLabel.set_scale(Vector2(.5 + success_progress, .5 + success_progress))
	else:
		$SuccessBackground.visible = false
		$SuccessLabel.visible = false


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


func _on_PlayAgainButton_pressed():
	var success = Utils.change_screen("res://Scenes/Lobby/Lobby.tscn", self)
	GameState.reset_gamestate()
	return success
