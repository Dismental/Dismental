extends Node

var next_scene

#onready var puzzle_label = $Control/VBoxContainer/PanelContainer/PuzzlesLeft
onready var roadmap_control = $Control
onready var bottom_button = $Control/Button


func _ready():
#	puzzle_label.text = "Minigames remaining: " + str(len(GameState.minigames))
	GameState.start_timer(get_node("CanvasLayer/Timer/MarginContainer/TimeCounter"))
	GameState.connect("timer_timeout", self, "_on_timer_timeout")
	GameState.connect("update_remaining_text", self, "_update_remaining_text")
	GameState.connect("defused", self, "_defused")
	GameState.connect("load_roadmap", self, "_load_roadmap")
	$Control.connect("wait_time_lobby_over", self, "_on_wait_time_lobby_over")

	# If current player is not the host
	if not get_tree().is_network_server():
		get_node("Control/Button").hide()


func _on_wait_time_lobby_over():
	print("WAIT TIME OVER!")


func _load_roadmap():
	$Control.show_next_minigame()


func _on_timer_timeout():
	return Utils.change_screen("res://Scenes/LoseScene.tscn", self)


func _on_start_minigame_pressed():
	GameState.start_minigame(bottom_button)
	bottom_button.release_focus()


func game_over():
	return Utils.change_screen("res://Scenes/LoseScene.tscn", self)


#func _update_remaining_text(text):
#	rpc("_update_minigames_remaing_text", text)


#remotesync func _update_minigames_remaing_text(num):
#	puzzle_label.text = "Minigames remaining: " + num


func _defused():
	rpc("_on_defuse")


remotesync func _on_defuse():
	GameState.defused()
	$Control/VBoxContainer/HBoxContainer/ExampleBomb/Title.text = "Defused"

	var date = OS.get_date().get("day")
	date += "/" + OS.get_date().get("month")
	date += "/" + OS.get_date().get("year")
	ScoreManager.add_score(Score.new(GameState.team_name,
		GameState.difficulty, GameState.timer.get_time_left(), date))

	return Utils.change_screen("res://Scenes/WinScene.tscn", self)
