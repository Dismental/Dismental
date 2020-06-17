extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var scroll_down_animation = false
var scroll_down_anim_progress = 0
const scroll_down_amount = 500
const scroll_down_anim_duration = 1 / 60 / .7


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func calc_scroll_pos(progress):
	return (1.0 - pow(1.0 - progress, 6)) * scroll_down_amount


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if scroll_down_animation:
		scroll_down_anim_progress += 1 * delta
		scroll_down_anim_progress = min(scroll_down_anim_progress, 1)
		self.margin_top = -calc_scroll_pos(scroll_down_anim_progress)
		if scroll_down_anim_progress >= 1:
			scroll_down_animation = false


func _on_Button2_pressed():
	scroll_down_animation = true
