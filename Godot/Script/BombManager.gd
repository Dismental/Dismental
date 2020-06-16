extends Node

var timer
var wait_time = 180

var timer_label
var running = false
var last_label_update
var next_scene

var minigame_index = 0
var minigames = ["Hack", "Align", "Cut", "Dissolve"]

onready var puzzle_label = $Control/VBoxContainer/PanelContainer/PuzzlesLeft
onready var bottom_button = $Control/VBoxContainer/PanelContainer/Button


func _ready():
	puzzle_label.text = "Minigames remaining: " + str(len(minigames))
	last_label_update = wait_time

	timer_label = get_node("CanvasLayer/TimeCounter")

	timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout",self,"_on_timer_timeout")
	timer.set_wait_time(wait_time)

	add_child(timer)

	_set_timer_label(wait_time)

	running = true
	timer.start()

	if not get_tree().is_network_server():
		get_node("Control/VBoxContainer/PanelContainer/Button").hide()


func _process(_delta):
	if running:
		var time_left = int(round(timer.get_time_left()))
		if last_label_update != time_left:
			last_label_update = time_left
			_set_timer_label(time_left)


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
	print("TIME'S UP")
	print("BOOOOOOM")
	print("Bomb exploded...")


func _on_start_minigame_pressed():
	if len(minigames) - minigame_index > 0:
		Network.start_minigame(minigames[minigame_index])
		bottom_button.release_focus()
		minigame_index += 1
		rpc("_update_minigames_remaing_text", str(len(minigames) - minigame_index))
		if len(minigames) - minigame_index == 0:
			bottom_button.text = "Defuse Bomb"
	else:
		rpc("_on_defuse")


func game_over():
	return Utils.change_screen("res://Scenes/LoseScene.tscn", self)


remotesync func _update_minigames_remaing_text(num):
	puzzle_label.text = "Minigames remaining: " + num

remotesync func _on_defuse():
	running = false
	timer.stop()
	$Control/VBoxContainer/HBoxContainer/ExampleBomb/Title.text = "Defused"
	return Utils.change_screen("res://Scenes/WinScene.tscn", self)
