extends PanelContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#const DEFAULT_TIMER_START_VALUE = 600000
#var timerValue = DEFAULT_TIMER_START_VALUE
#var lastTimerUpdate = OS.get_ticks_msec()
#var paused = false
#
#const BLINK_INTERVAL = 30
#
#var blink = false
#var blinkState = -BLINK_INTERVAL
#onready var timerText = self.get_child(0).get_child(0)

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass
#	timerText.text = "10:00"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#	timerText.set_text(getFormattedTimerValue())
#	if blink:
#		if blinkState < 0:
#			timerText.text = ""
#		blinkState += 1
#		if blinkState > BLINK_INTERVAL:
#			blinkState = -BLINK_INTERVAL
#
#	updateTimer()
#	update()

func _draw():
	_draw_screws(Rect2(0,0,self.get_rect().size.x,self.get_rect().size.y))

#func continueTimer():
#	paused = false
#	blink = false

#func updateTimer():
#	if not paused:
#		timerValue -= OS.get_ticks_msec() - lastTimerUpdate
#		lastTimerUpdate = OS.get_ticks_msec()
#	if timerValue < 0:
#		pauseTimer()
#		timerValue = 0
#		print("Done")
#
#func pauseTimer():
#	paused = true
#	blink = true
#
#func toggleTimer():
#	if paused:
#		continueTimer()
#	else:
#		pauseTimer()
#
#func clearTimer():
#	timerValue = DEFAULT_TIMER_START_VALUE
#
#func extendTimer(minutes = 0, seconds = 0):
#	timerValue += minutes * 60 * 1000 + seconds * 1000
#
#func shortenTimer(minutes = 0, seconds = 0):
#	timerValue -= minutes * 60 * 1000 + seconds * 1000
#	if timerValue < 0:
#		timerValue = 0
#
#func getFormattedTimerValue():
#	var minutes = (timerValue / 1000 / 60) % 60
#	var seconds = timerValue / 1000 % 60
#	return "%02d:%02d" % [minutes,seconds]
func _draw_screws(rect):
	var x = rect.position.x
	var y = rect.position.y
	draw_circle(Vector2(x + 10, y + 10), 2, Color.black)
	draw_circle(Vector2(x + 18, y + 10), 2, Color.black)
	draw_circle(Vector2(x + 10, y + 18), 2, Color.black)

	y += rect.size.y
	draw_circle(Vector2(x + 10, y - 10), 2, Color.black)
	draw_circle(Vector2(x + 18, y - 10), 2, Color.black)
	draw_circle(Vector2(x + 10, y - 18), 2, Color.black)

	x += rect.size.x
	draw_circle(Vector2(x - 10, y - 10), 2, Color.black)
	draw_circle(Vector2(x - 18, y - 10), 2, Color.black)
	draw_circle(Vector2(x - 10, y - 18), 2, Color.black)

	y -= rect.size.y
	draw_circle(Vector2(x - 10, y + 10), 2, Color.black)
	draw_circle(Vector2(x - 18, y + 10), 2, Color.black)
	draw_circle(Vector2(x - 10, y + 18), 2, Color.black)
