extends Control


var scrollAnimating = false
var scrollProgress = 0
var scrollAmount = 0
# true = down
# false = up
var scrollDirection = true

func startScrollAnimation(direction):
	scrollDirection = direction
	scrollProgress = 0
	scrollAnimating = true


func _ready():
	scrollAmount = $Background.get_rect().size.y - self.get_rect().size.y
	
func calc_scroll_pos(progress):
	var frac = (1.0 - pow(1.0 - progress, 6))
	if scrollDirection:
		return scrollAmount * frac
	else:
		return scrollAmount * (1-frac)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if scrollAnimating and scrollProgress <= 1:
		scrollProgress += 1 * delta
		self.margin_top = -calc_scroll_pos(scrollProgress)
		$SettingsPanel.margin_top = 515 - self.margin_top / 2
		$SettingsPanel.margin_bottom = 515 - self.margin_top / 2 + $SettingsPanel.get_rect().size.y
		if scrollProgress >= 1:
			scrollAnimating = false


func _on_Button2_pressed():
	$MissionPanel/CreateMissionPanel.visible = true
	$MissionPanel/JoinMissionPanel.visible = false
	startScrollAnimation(true)


func _on_JoinMissionButton_pressed():
	$MissionPanel/CreateMissionPanel.visible = false
	$MissionPanel/JoinMissionPanel.visible = true
	startScrollAnimation(true)


func _on_CreateMissionBtn2_pressed():
	startScrollAnimation(false)
