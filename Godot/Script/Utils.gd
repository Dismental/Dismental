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
static func _change_screen(path: String, s_node : Node):
	var node = load(path)
	var parent = s_node.get_parent()
	node = node.instance()
	if is_instance_valid(parent):
		parent.add_child(node)
		parent.remove_child(s_node)
	else: 
		print("node has no parent, so is connected to root!")
	s_node.queue_free()
	if s_node.is_queued_for_deletion():
		print("deleting")
	else:
		push_error("can't delete" + str(s_node))
