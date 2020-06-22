extends Node


# receives notification from the OS like quit, or mouse enter/exit.
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		ScoreManager.save_scores()
		print("saved")
