extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var scrollDownAnimating = false
var scrollDownProgress = 0
var scrollDownAmount = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	scrollDownAmount = $Background.get_rect().size.y - self.get_rect().size.y
	pass # Replace with function body.
	
func calc_scroll_pos(progress):
	var frac = (1.0 - pow(1.0 - progress, 6))
	return scrollDownAmount * frac


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if scrollDownAnimating and scrollDownProgress <= 1:
		scrollDownProgress += 1 * delta
		self.margin_top = -calc_scroll_pos(scrollDownProgress)
		$SettingsPanel.margin_top = 515 - self.margin_top / 2
		$SettingsPanel.margin_bottom = 515 - self.margin_top / 2 + $SettingsPanel.get_rect().size.y
		if scrollDownProgress >= 1:
			scrollDownAnimating = false


func _on_Button2_pressed():
	$MissionPanel/CreateMissionPanel.visible = true
	$MissionPanel/JoinMissionPanel.visible = false
	scrollDownAnimating = true


func _on_JoinMissionButton_pressed():
	$MissionPanel/CreateMissionPanel.visible = false
	$MissionPanel/JoinMissionPanel.visible = true
	scrollDownAnimating = true
