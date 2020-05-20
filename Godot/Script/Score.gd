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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _save():
	var save_dict = {
		"team" : team,
		"level" : level,
		"time" : time,
		"date" : date,
	}
	return save_dict


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
