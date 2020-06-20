extends Control


func _ready():
	instance_panels()


func _on_BackButton_pressed():
	Utils.change_screen("res://Scenes/MainMenu.tscn", self)


# Makes ScorePanels based on the scores that currently exist within ScoreManager.
func instance_panels():
	var scores = ScoreManager.get_scores()
	var Scorepanel = preload("res://Scenes/ScoreScenes/ScorePanel.tscn")
	var pos = 1
	for score in scores:
		var n_panel = Scorepanel.instance()
		n_panel.get_node("Position").text = str(pos)
		n_panel.get_node("TeamName").text = score.team
		n_panel.get_node("Difficulty").text = score.difficulty
		n_panel.get_node("Time").text = score.time
		n_panel.get_node("Date").text = score.date
		$ScrollBackground/ScoresContainer/VBoxContainer.add_child(n_panel)
		pos += 1
	# A last control node is added, as somehow the last node will not be shown.
	# Tried to fix this, but seems like an intendend behavior(?) in Godot.
	# The other extra control node allows the scrollcontainer to scroll a bit past
	# the first element (design choice)
	$ScrollBackground/ScoresContainer/VBoxContainer.add_child(Control.new())
	print("Scorepanels instanced")
