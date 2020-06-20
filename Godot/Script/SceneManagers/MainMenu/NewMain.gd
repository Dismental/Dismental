extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var scroll_animating = false
var scroll_progress = 0
var scroll_amount = 0
# true = down
# false = up
var scroll_direction = true

func start_scroll_animation(direction):
	scroll_direction = direction
	scroll_progress = 0
	scroll_animating = true


# Called when the node enters the scene tree for the first time.
func _ready():
	scroll_amount = $Background.get_rect().size.y - self.get_rect().size.y

func calc_scroll_pos(progress):
	var frac = (1.0 - pow(1.0 - progress, 6))
	if scroll_direction:
		return scroll_amount * frac
	else:
		return scroll_amount * (1-frac)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if scroll_animating and scroll_progress <= 1:
		scroll_progress += 1 * delta
		self.margin_top = -calc_scroll_pos(scroll_progress)
		$SettingsPanel.margin_top = 515 - self.margin_top / 2
		$SettingsPanel.margin_bottom = 515 - self.margin_top / 2 + $SettingsPanel.get_rect().size.y
		if scroll_progress >= 1:
			scroll_animating = false

func _on_Button2_pressed():
	$MissionPanel/CreateMissionPanel.visible = true
	$MissionPanel/JoinMissionPanel.visible = false
	start_scroll_animation(true)

func _on_JoinMissionButton_pressed():
	$MissionPanel/CreateMissionPanel.visible = false
	$MissionPanel/JoinMissionPanel.visible = true
	start_scroll_animation(true)

func _on_CreateMissionBtn2_pressed():
	start_scroll_animation(false)
