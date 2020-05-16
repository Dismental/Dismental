extends "res://addons/gut/test.gd"

func test_file_count_in_this_directory():
	var Utils = load('res://Script/Utils.gd').new()
	assert_true(Utils._count_files_in_dir("res://test/unit/MiniGames/") >= 1)


