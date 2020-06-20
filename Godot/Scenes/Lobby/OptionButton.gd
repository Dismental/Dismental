extends OptionButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_item("EASY")
	self.add_item("MEDIUM")
	self.add_item("HARD")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
