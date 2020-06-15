extends Node

static func _count_files_in_dir(path):
	var count = 0
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			count += 1

	dir.list_dir_end()
	return count

# Changes the node from s_node with one made from the scene resource given in path
func change_screen(path: String, s_node : Node):
	var NewNode = load(path)
	var parent = s_node.get_parent()
	NewNode = NewNode.instance()
	if is_instance_valid(parent):
		parent.add_child(NewNode)
		parent.remove_child(s_node)
	else:
		print("node has no parent, so is connected to root!")
	s_node.queue_free()
	if s_node.is_queued_for_deletion():
		return true
	else:
		push_error("can't delete" + str(s_node))
		return false

func add_scene(path: String, parent : Node):
	var new_node = load(path)
	if new_node == null:
		print("no scene found with path: " + path)
	else:
		new_node = new_node.instance()
		parent.add_child(new_node)
