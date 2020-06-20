extends MarginContainer

var limit = 16

var current_text = ''
var cursor_line = 0
var cursor_column = 0

func _on_CreateMissionBtn_pressed():
	if get_input_playername().empty():
		popup("Playername can't be empty!")
	else:
		Network.player_name = get_input_playername()
		Network.create_server()
		return Utils.change_screen("res://Scenes/Lobby/Lobby.tscn", get_parent().get_parent())


func popup(text: String):
#	$AcceptDialog.dialog_text = text
#	$AcceptDialog.popup_centered()
# TODO implement custom popup dialog
	pass


func get_input_playername():
	return $VBoxContainer/PlayerName/Input.text

