extends Node

var next_scene

onready var puzzle_label = $Control/VBoxContainer/PanelContainer/PuzzlesLeft
onready var bottom_button = $Control/VBoxContainer/PanelContainer/Button


func _ready():
	puzzle_label.text = "Minigames remaining: " + str(len(GameState.minigames))

	GameState.start_timer(get_node("CanvasLayer/TimeCounter"))
	GameState.connect("timer_timeout", self, "_on_timer_timeout")
	GameState.connect("update_remaining_text", self, "_update_remaining_text")
	GameState.connect("defused", self, "_defused")

	if not get_tree().is_network_server():
		get_node("Control/VBoxContainer/PanelContainer/Button").hide()


func _on_timer_timeout():
	return Utils.change_screen("res://Scenes/LoseScene.tscn", self)


func _on_start_minigame_pressed():
	GameState.start_minigame(bottom_button)
	bottom_button.release_focus()


func game_over():
	return Utils.change_screen("res://Scenes/LoseScene.tscn", self)


func _update_remaining_text(text):
	rpc("_update_minigames_remaing_text", text)


remotesync func _update_minigames_remaing_text(num):
	puzzle_label.text = "Minigames remaining: " + num


func _defused():
	rpc("_on_defuse")


remotesync func _on_defuse():
	GameState.defused()
	$Control/VBoxContainer/HBoxContainer/ExampleBomb/Title.text = "Defused"

	var date = OS.get_date().get("day")
	date += "/" + OS.get_date().get("month")
	date += "/" + OS.get_date().get("year")
	ScoreManager.add_score(Score.new(Network.player_name,
		Network.player_info.size(), timer.get_time_left(), date))

	return Utils.change_screen("res://Scenes/WinScene.tscn", self)
