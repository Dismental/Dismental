extends Control

onready var button_click_sound = $ButtonClick


func _ready():
	instance_panels()


func _on_BackButton_pressed():
	button_click_sound.play()
	get_parent().remove_child(self)
	self.queue_free()


# Makes ScorePanels based on the scores that currently exist within ScoreManager.
func instance_panels():
	ScoreManager.sort_scores()
	var scores = ScoreManager.get_scores()
	var Scorepanel = preload("res://Scenes/ScoreScenes/ScorePanel.tscn")
	var pos = 1
	for score in scores:
		var n_panel = Scorepanel.instance()
		n_panel.get_node("Position").text = str(pos)
		n_panel.get_node("TeamName").text = score.get_team()
		n_panel.get_node("Difficulty").text = score.get_difficulty()
		n_panel.get_node("Time").text = score.get_time()
		n_panel.get_node("Date").text = score.get_date()
		$ScrollBackground/ScoresContainer/VBoxContainer.add_child(n_panel)
		pos += 1
	# A last control node is added, as somehow the last node will not be shown.
	# Tried to fix this, but seems like an intendend behavior(?) in Godot.
	# The other extra control node allows the scrollcontainer to scroll a bit past
	# the first element (design choice)
	$ScrollBackground/ScoresContainer/VBoxContainer.add_child(Control.new())
	print("Scorepanels instanced")
