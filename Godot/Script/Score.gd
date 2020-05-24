extends Object
class_name Score

var team : String 
var level : String
var time : String
var date : String

func _init(team_name: String, level_name: String, completed_time: String, completed_date: String):
	team = team_name
	level = level_name
	time = completed_time
	date = completed_date


func _save():
	var save_dict = {
		"team" : team,
		"level" : level,
		"time" : time,
		"date" : date,
	}
	return save_dict
