extends Node

signal timer_timeout
signal update_remaining_text(text)
signal defused
signal update_difficulty
signal update_team_name
signal load_roadmap

enum Difficulty {
	EASY,
	MEDIUM,
	HARD,
}

var timer
var wait_time = 60 * 10
var timer_label
var running = false

var minigame_index = 0
var minigames = ["Hack", "Cut", "Align", "Dissolve"]
var defusers = []
var last_label_update

var difficulty = Difficulty.keys()[0]
var team_name = "BITs"


func _process(_delta):
	if running:
		var time_left = int(round(timer.get_time_left()))
		if last_label_update != time_left:
			last_label_update = time_left
			_set_timer_label(time_left)


func assign_roles():
	randomize()
	var players = get_tree().get_network_connected_peers()
	players.append(1)
	var index = randi() % len(players)
	for mg in minigames:
		if mg != "Align":
			defusers.append(players[index])
			index += 1
			if index >= len(players):
				index = 0
		else:
			defusers.append(-1)
	rpc('set_defuser_roles', defusers)


remotesync func set_defuser_roles(roles):
	defusers = roles

func reset_gamestate():
	wait_time = 60 * 10
	minigame_index = 0
	minigames = ["Hack", "Cut", "Align", "Dissolve"]
	defusers = []
	assign_roles()
	Network.clear_ready_players()
	update_difficulty(difficulty)
	update_team_name(team_name)


func start_timer(timer_node):
	timer_label = timer_node
	last_label_update = wait_time

	timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.set_wait_time(wait_time)

	timer_node.add_child(timer)

	_set_timer_label(wait_time)

	running = true
	timer.start()


func format_time(sec):
	var minutes = 0

	while sec >= 60:
		minutes += 1
		sec -= 60

	if minutes < 10:
		minutes = "0" + str(minutes)
	else:
		minutes = str(minutes)

	if sec < 10:
		sec = "0" + str(sec)
	else:
		sec = str(sec)
	return minutes + ":" + sec


func _set_timer_label(sec):
	var curr_time = format_time(sec)
	timer_label.text = curr_time


func load_roadmap():
	emit_signal("load_roadmap")


func _on_timer_timeout():
	emit_signal("timer_timeout")


func defused():
	running = false
	timer.stop()


func stop_running():
	running = false


func start_minigame(button_reference):
	if len(minigames) - minigame_index > 0:
		Network.start_minigame(minigames[minigame_index])
		rpc("increment_minigame_index")
		if len(minigames) - minigame_index == 0:
			button_reference.text = "Defuse Bomb"
	else:
		emit_signal("defused")

remotesync func increment_minigame_index():
	minigame_index += 1

func init_lobby_options(id: int):
	rpc_id(id, "update_difficulty", difficulty)
	rpc_id(id, "update_team_name", team_name)


func difficulty_changed(id: int):
	difficulty = Difficulty.keys()[id]
	rpc("update_difficulty", difficulty)


remote func update_difficulty(diff):
	difficulty = diff
	match diff:
		"EASY":
			emit_signal("update_difficulty", 0)
		"MEDIUM":
			emit_signal("update_difficulty", 1)
		"HARD":
			emit_signal("update_difficulty", 2)
		_:
			print("Difficulty not found!")


func team_name_changed(name: String):
	team_name = name
	rpc("update_team_name", team_name)


remote func update_team_name(name:String):
	team_name = name
	emit_signal("update_team_name", team_name)
