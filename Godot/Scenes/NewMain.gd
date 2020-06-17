extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var scroll_down_animating = false
var scroll_down_anim_progress = 0
var scroll_down_amount = Vector2(0,0)


# Called when the node enters the scene tree for the first time.
func _ready():
	var createMissionPanel = $CreateMissionPanel
	print(createMissionPanel.get_rect())
	pass # Replace with function body.
	
func calc_scroll_pos(progress):
	var frac = (1.0 - pow(1.0 - progress, 6))
	return scroll_down_amount * frac


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if scroll_down_animating:
		scroll_down_anim_progress += 1 * delta
		scroll_down_anim_progress = min(scroll_down_anim_progress, 1)
		self.margin_top = -calc_scroll_pos(scroll_down_anim_progress).y
		self.margin_left = -calc_scroll_pos(scroll_down_anim_progress).x
		$SettingsPanel.margin_top = 515 - self.margin_top
		if scroll_down_anim_progress >= 1:
			scroll_down_animating = false


func _on_Button2_pressed():
	var centerPanel = $CreateMissionPanel.get_rect().position + $CreateMissionPanel.get_rect().size / 2
	var centerScreen = self.get_rect().position + self.get_rect().size / 2
	scroll_down_animating = true
	scroll_down_amount.x = centerPanel.x - centerScreen.x
	scroll_down_amount.y = centerPanel.y - centerScreen.y


func _on_JoinMissionButton_pressed():
	var centerPanel = $JoinMissionPanel.get_rect().position + $JoinMissionPanel.get_rect().size / 2
	var centerScreen = self.get_rect().position + self.get_rect().size / 2
	scroll_down_animating = true
	print(centerPanel.y)
	scroll_down_amount.x = centerPanel.x - centerScreen.x
	scroll_down_amount.y = centerPanel.y - centerScreen.y
