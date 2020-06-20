extends Node

signal timer_timeout
signal update_remaining_text(text)
signal defused
signal update_difficulty
signal update_team_name

enum Difficulty {
	EASY,
	MEDIUM,
	HARD,
}

var timer
var wait_time = 60 * 10
var timer_label
var running = false

var squadname = ""
var minigame_index = 0
var minigames = ["Hack", "Align", "Cut", "Dissolve"]
var defusers = []
var last_label_update

var difficulty = Difficulty.keys()[0]
var team_name = "Bomb Squad"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	if running:
		var time_left = int(round(timer.get_time_left()))
		if last_label_update != time_left:
			last_label_update = time_left
			_set_timer_label(time_left)


func assign_roles():
	var players = get_tree().get_network_connected_peers()
	var index = randi() % len(players)
	for mg in minigames:
		if mg != "Align":
			defusers.append(players[index])
			index += 1
			if index >= len(players):
				index = 0
		else:
			defusers.append(-1)


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


func _set_timer_label(sec):
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

	timer_label.text = minutes + ":" + sec


func _on_timer_timeout():
	emit_signal("timer_timeout")


func defused():
	running = false
	timer.stop()


func start_minigame(button_reference):
	if len(minigames) - minigame_index > 0:
		Network.start_minigame(minigames[minigame_index])
		minigame_index += 1
		emit_signal("update_remaining_text", str(len(minigames) - minigame_index))
		if len(minigames) - minigame_index == 0:
			button_reference.text = "Defuse Bomb"
	else:
		emit_signal("defused")


remotesync func update_squad_name(new_name):
	squadname = new_name


func init_lobby_options(id: int):
	rpc_id(id, "update_difficulty", difficulty)
	rpc_id(id, "update_team_name", team_name)


func difficulty_changed(id: int):
	difficulty = Difficulty.keys()[id]
	rpc("update_difficulty", difficulty)


remote func update_difficulty(diff):
	difficulty = diff
	emit_signal("update_difficulty", difficulty)


func team_name_changed(name: String):
	team_name = name
	rpc("update_team_name", team_name)


remote func update_team_name(name:String):
	team_name = name
	emit_signal("update_team_name", team_name)
