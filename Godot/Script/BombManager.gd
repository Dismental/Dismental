extends Node

var timer
var wait_time = 100

var timer_label
var running = false
var last_label_update
var next_scene

func _ready():
	last_label_update = wait_time

	timer_label = get_node("CanvasLayer/TimeCounter")

	timer = Timer.new()
	timer.one_shot = true

	timer.connect("timeout",self,"_on_timer_timeout")
	add_child(timer)
	timer.set_wait_time(wait_time)
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
	Network.start_minigame("Cut")
