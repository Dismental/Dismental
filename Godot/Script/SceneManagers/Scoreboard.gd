extends Control


func _ready():
	instance_panels()

func _on_BackButton_pressed():
	Utils._change_screen("res://Scenes/MainMenu.tscn", self)

func change_scene(filename):
	if get_tree().change_scene(filename) != OK:
		print("Error loading " + str(filename))

# Makes ScorePanels based on the scores that currently exist within ScoreManager.
func instance_panels():
	var scores = ScoreManager.get_scores()	
	var scorepanel = preload("res://Scenes/ScoreScenes/ScorePanel.tscn")
	var pos = 1
	for score in scores:
		var n_panel = scorepanel.instance()
		n_panel.get_node("HBoxContainer/Date").bbcode_text = "[center]Date:\n" + score.date + "[/center]"
		n_panel.get_node("HBoxContainer/TeamName").bbcode_text = "[center]Team:\n" + score.team + "[/center]"
		n_panel.get_node("HBoxContainer/Time").bbcode_text = "[center]Time:\n" + score.time + "[/center]"
		n_panel.get_node("HBoxContainer/Level").bbcode_text = "[center]Level:\n" + score.level + "[/center]"
		n_panel.get_node("HBoxContainer/Position").bbcode_text = "[center]Pos:\n" + str(pos) + "[/center]"
		$ScrollContainer/VBoxContainer.add_child(n_panel)
		pos += 1
	# A last control node is added, as somehow the last node will not be shown. Tried to fix this, but seems like
	# an intendend behavior(?) in Godot.
	# The other extra control node allows the scrollcontainer to scroll a bit past the first element (design choice)
	$ScrollContainer/VBoxContainer.add_child(Control.new())
	$ScrollContainer/VBoxContainer.add_child(Control.new())
	print("Scorepanels instanced")
