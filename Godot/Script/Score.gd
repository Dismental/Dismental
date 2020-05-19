extends Node
class_name Score

var team : String 
var level : String
var time : String
var date : String

func _init(teamName: String, levelName: String, completedTime: String, completedDate: String):
	add_to_group("Persist")
	team = teamName
	level = levelName
	time = completedTime
	date = completedDate

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
