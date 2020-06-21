class_name Score
extends Object


var _team: String
var _difficulty: String
var _time: String
var _date: String


func _init(team_name: String, diff: String, completed_time: String, completed_date: String):
	_team = team_name
	_difficulty = diff
	_time = completed_time
	_date = completed_date


func save():
	var save_dict = {
		"team" : _team,
		"difficulty" : _difficulty,
		"time" : _time,
		"date" : _date,
	}
	return save_dict


func get_team():
	return _team


func set_team(team):
	_team = team


func get_difficulty():
	return _difficulty


func set_difficulty(difficulty):
	_difficulty = difficulty


func get_time():
	return _time


func set_time(time):
	_time = time


func get_date():
	return _date


func set_date(date):
	_date = date
