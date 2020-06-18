extends Control


func _ready():
	var score = ScoreManager.get_scores().back()
	ScoreManager.sort_scores()
	var score_pos = ScoreManager.get_scores().find(score) + 1
	instance_score(score, score_pos)


func instance_score(score: Score, score_pos : int):
	var Scorepanel = preload("res://Scenes/ScoreScenes/ScorePanel.tscn")
	var n_panel = Scorepanel.instance()
	n_panel.get_node("HBoxContainer/Date").bbcode_text \
		= "[center]Date:\n" + score.date + "[/center]"
	n_panel.get_node("HBoxContainer/TeamName").bbcode_text \
		= "[center]Team:\n" + score.team + "[/center]"
	n_panel.get_node("HBoxContainer/Time").bbcode_text \
		= "[center]Time:\n" + score.time + "[/center]"
	n_panel.get_node("HBoxContainer/Level").bbcode_text \
		= "[center]Level:\n" + score.level + "[/center]"
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
