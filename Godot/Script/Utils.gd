
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
