extends TextEdit

export(int) var limit = 10

var current_text = ''
var cursor_line = 0
var cursor_column = 0


func _on_InputGameID_text_changed():
	_limit_amount_of_chars()


func _limit_amount_of_chars():
	# Limits the amount of chars that can be entered
	var new_text : String = self.text
	if new_text.length() > limit:
		self.text = current_text
		# when replacing the text, the cursor will get moved to the beginning of the
		# text, so move it back to where it was
		self.cursor_set_line(cursor_line)
		self.cursor_set_column(cursor_column)

	current_text = self.text
	cursor_line = self.cursor_get_line()
	cursor_column = self.cursor_get_column()
