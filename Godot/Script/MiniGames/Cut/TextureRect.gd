extends TextureRect

const PATTERN_SIZE = 96

var pattern_movement = 0

func _process(_delta):
	# Move pattern from -96 to 0
	# By looping this, the red lines in the pattern appear to be constantly moving to the right
	pattern_movement = int(pattern_movement + 1) % PATTERN_SIZE - PATTERN_SIZE
	self.margin_left = pattern_movement
	
	# Use the movement value of the pattern to let the pattern blink slowly
	# by setting the alpha value to a sin function of the movement.
	# This leads in the pattern slowly blinking between alpha=1/3 and alpha=2/3
	var alpha_base_val = 1.0/3
	var alpha_variation = abs(sin(PI*(float(pattern_movement) / 96))) / 3
	self.modulate = Color(1,1,1, alpha_base_val + alpha_variation)
