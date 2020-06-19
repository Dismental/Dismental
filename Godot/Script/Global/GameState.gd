extends Node

signal timer_timeout
signal update_remaining_text(text)
signal defused

enum Difficulty {
	EASY,
	MEDIUM,
	HARD,
}

var timer
var wait_time = 60 * 10
var timer_label
var running = false

var squadname
var minigame_index = 0
var minigames = ["Hack", "Align", "Cut", "Dissolve"]
var last_label_update

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	if running:
		var time_left = int(round(timer.get_time_left()))
		if last_label_update != time_left:
			last_label_update = time_left
			_set_timer_label(time_left)


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
