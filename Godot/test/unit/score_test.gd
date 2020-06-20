extends "res://addons/gut/test.gd"


var score


func before_each():
	score = Score.new("test_team", "easy", "12:34:56", "01/01/2000")


func test_score_has_methods():
	assert_has_method(score, "save")


func test_score_accessors():
	assert_accessors(score, "team", "test_team", "new_teamname")
	assert_accessors(score, "difficulty", "easy", "hard")
	assert_accessors(score, "time", "12:34:56", "11:39:55")
	assert_accessors(score, "date", "01/01/2000", "10/05/2020")


func test_save_method():
	var expected_dict = {
		"team" : "test_team",
		"difficulty" : "easy",
		"time" : "12:34:56",
		"date" : "01/01/2000",
	}
	assert_eq(score.save().hash(), expected_dict.hash(), "Expected save function to return dict")
