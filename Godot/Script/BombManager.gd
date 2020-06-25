extends Node

var next_scene

onready var roadmap_control = $Control
onready var bottom_button = $Control/StartNextTask
onready var countdown_timer = $Control/CountDown


func _ready():
	GameState.start_timer(get_node("CanvasLayer/Timer/MarginContainer/TimeCounter"))
	GameState.connect("timer_timeout", self, "_on_timer_timeout")
	GameState.connect("defused", self, "_defused")
	GameState.connect("load_roadmap", self, "_load_roadmap")

	Network.connect("player_disconnected", self, "_player_disconnect")

	if get_tree().is_network_server():
		GameState.assign_roles()

	$Control.connect("wait_time_lobby_over", self, "_on_wait_time_lobby_over")

	# If current player is not the host
	if not get_tree().is_network_server():
		bottom_button.hide()


func _on_wait_time_lobby_over():
	if get_tree().get_network_unique_id() == Network.host:
		GameState.start_minigame(bottom_button)


func _load_roadmap():
	$Control.show_next_minigame()


func _on_timer_timeout():
	return Utils.change_screen("res://Scenes/LoseScene.tscn", self)


func _on_start_minigame_pressed():
	countdown_timer.stop()
	GameState.start_minigame(bottom_button)
	bottom_button.release_focus()


func _player_disconnect(id, name):
	if Network.host == id:
		GameState.reset_gamestate()
		if get_tree().get_root().has_node("VoiceStream"):
			var voice = get_tree().get_root().get_node("VoiceStream")
			voice.stop()
			voice.get_parent().remove_child(voice)
			voice.queue_free()
		Network.stop()
		var tree = get_tree()
		var succes = Utils.change_screen("res://Scenes/MainMenu.tscn", self)
		tree.get_root().find_node("MainMenu", true, false).popup(
			"Host disconnected")
	else:
		GameState.reset_gamestate()
		var tree = get_tree()
		var succes = Utils.change_screen("res://Scenes/Lobby/Lobby.tscn", self)

		tree.get_root().find_node("Lobby", true, false).popup(
			name + " disconnected\nLobby is closed, no new players can join")


func game_over():
	GameState.stop_running()
	return Utils.change_screen("res://Scenes/LoseScene.tscn", self)


func _defused():
	rpc("_on_defuse")


remotesync func _on_defuse():
	var end_time = GameState.format_time(int(round(GameState.timer.get_time_left())))
	GameState.defused()

	var date = str(OS.get_date().get("day"))
	date += "/" + str(OS.get_date().get("month"))
	date += "/" + str(OS.get_date().get("year"))
	ScoreManager.add_score(Score.new(GameState.team_name,
		GameState.difficulty, end_time, date))

	return Utils.change_screen("res://Scenes/WinScene.tscn", self)
