extends Control

var success_animate = true
var success_progress = 0

func _ready():
	$SuccessBackground.visible = true
	$SuccessLabel.visible = true

	var score : Score = ScoreManager.get_scores().back()
	ScoreManager.sort_scores()
	var score_pos = ScoreManager.get_scores().find(score) + 1
	$Squad.text = GameState.team_name
	$Squad/Members.add_item(Network.player_name)
	for player in Network.player_info.values():
		$Squad/Members.add_item(player)
	$Squad/Score.text += "\n" + str(score.time) + "\n"
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


func instance_score(score: Score, score_pos : int):
	var Scorepanel = preload("res://Scenes/ScoreScenes/ScorePanel.tscn")
	var n_panel = Scorepanel.instance()
	n_panel.get_node("HBoxContainer/Date").bbcode_text \
		= "[center]Date:\n" + score.date + "[/center]"
	n_panel.get_node("HBoxContainer/TeamName").bbcode_text \
		= "[center]Team:\n" + score.team + "[/center]"
	n_panel.get_node("HBoxContainer/Time").bbcode_text \
		= "[center]Time:\n" + score.time + "[/center]"
	n_panel.get_node("HBoxContainer/Difficulty").bbcode_text \
		= "[center]Difficulty:\n" + score.difficulty + "[/center]"
	n_panel.get_node("HBoxContainer/Position").bbcode_text \
		= "[center]Pos:\n" + str(score_pos) + "[/center]"
	add_child(n_panel)
	n_panel.set_position(Vector2(600, 500))


func _on_MainMenuButton_pressed():
	if get_parent().has_node("VoiceStream"):
		var voice = get_parent().get_node("VoiceStream")
		voice.stop()
		voice.get_parent().remove_child(voice)
		voice.queue_free()
	Network.stop()
	return Utils.change_screen("res://Scenes/MainMenu.tscn", self)


func _on_ScoreBoardButton_pressed():
	return Utils.add_scene("res://Scenes/ScoreScenes/Scoreboard.tscn", self)
