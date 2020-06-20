class_name Score
extends Object

var team : String
var difficulty : String
var time : String
var date : String


func _init(team_name: String, diff: String, completed_time: String, completed_date: String):
	team = team_name
	difficulty = diff
	time = completed_time
	date = completed_date


func save():
	var save_dict = {
		"team" : team,
		"difficulty" : difficulty,
		"time" : time,
		"date" : date,
	}
	return save_dict
