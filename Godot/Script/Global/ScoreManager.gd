extends Node

var scores = []


func _ready():
	load_scores()
	scores.sort_custom(CustomSort, "sort")


func get_scores():
	return scores


func add_score(score: Score):
	scores.append(score)


func sort_scores():
	scores.sort_custom(CustomSort, "sort")


func save_scores():
	var save_file = File.new()
	save_file.open("user://scoresave.save", File.WRITE)
	for score in scores:
		var score_data = score.save()
		save_file.store_line(to_json(score_data))
	save_file.close()


func load_scores():
	var save_file = File.new()
	if not save_file.file_exists("user://scoresave.save"):
		print("No scoresave found!")
		return
	save_file.open("user://scoresave.save", File.READ)
	while save_file.get_position() < save_file.get_len():
		var score_data = parse_json(save_file.get_line())
		var score = Score.new(
				score_data["team"],
				score_data["difficulty"],
				score_data["time"],
				score_data["date"]
			)
		scores.append(score)
	save_file.close()


#This is for testing purposes, should be removed before building!
func first_run():
	scores.append(Score.new("tst2", "easy", "03:01", "01/01/2000"))
	scores.append(Score.new("tst2","easy", "03:01", "01/01/2000"))
	scores.append(Score.new("tst2", "easy", "03:01", "01/01/2000"))
	scores.append(Score.new("tst", "medium", "03:00", "01/01/2000"))
	scores.append(Score.new("tst2", "medium", "03:01", "01/01/2000"))
	scores.append(Score.new("tst2", "hard", "03:01", "01/01/2000"))
	scores.append(Score.new("tst", "hard", "03:00", "01/01/2000"))
	scores.append(Score.new("tst2", "easy", "03:01", "01/01/2000"))
	scores.append(Score.new("tst2", "medium", "03:03", "01/01/2000"))
	scores.append(Score.new("tst2", "medium", "03:01", "01/01/2000"))
	scores.append(Score.new("tst2", "hard", "03:01", "01/01/2000"))
	scores.append(Score.new("tst2", "easy", "03:03", "01/01/2000"))
	scores.append(Score.new("laatste", "hard", "03:06", "01/01/2000"))
	scores.append(Score.new("tst2", "easy", "03:02", "01/01/2000"))
	save_scores()


class CustomSort:
	static func sort(a, b):
		return a.get_time() < b.get_time()
