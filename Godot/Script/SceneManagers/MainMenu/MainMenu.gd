extends Control


var scroll_animating = false
var scroll_progress = 0
var scroll_amount = 0
var scroll_down = true


func start_scroll_animation(direction):
	scroll_down = direction
	scroll_progress = 0
	scroll_animating = true


func _ready():
	scroll_amount = $Background.get_rect().size.y - self.get_rect().size.y

func calc_scroll_pos(progress):
	var frac = (1.0 - pow(1.0 - progress, 6))
	if scroll_down:
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


func _on_CreateMissionButton_pressed():
	set_panel_visible($MissionPanel/CreateMissionPanel, true)
	set_panel_visible($MissionPanel/JoinMissionPanel, false)
	start_scroll_animation(true)


func _on_JoinMissionButton_pressed():
	set_panel_visible($MissionPanel/CreateMissionPanel, false)
	set_panel_visible($MissionPanel/JoinMissionPanel, true)
	start_scroll_animation(true)


func _on_BackButton_pressed():
	start_scroll_animation(false)


func popup(text: String):
	var p_up = $Popup
	p_up.change_text(text)
	p_up.popup_centered()


func set_panel_visible(node, vis):
	node.visible = vis
