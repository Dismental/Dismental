extends "res://addons/gut/test.gd"


func test_move_bar():
	var inst = partial_double('res://Script/MiniGames/HackGameManager.gd').new()
	inst.bar = Area2D.new()
	
	stub(inst, "_get_input_pos").to_return(Vector2(100, 100))
	inst._move_bar()
	assert_eq(inst.bar.position.y, 100.0)

	stub(inst, "_get_input_pos").to_return(Vector2(0, 1000))
	inst._move_bar()
	assert_eq(inst.bar.position.y, 1000.0)

	stub(inst, "_get_input_pos").to_return(Vector2(-100, 10))
	inst._move_bar()
	assert_eq(inst.bar.position.y, 10.0)

func test_create_label():
	var inst = load('res://Script/MiniGames/HackGameManager.gd').new()
	inst.label_nodes = Node.new()

	var pos = Vector2(100, 100)
	var text = "Test"
	inst._create_label_node(pos, text)
	assert_eq(len(inst.normal_labels), 1)
	assert_eq(inst.normal_labels[0].position, pos)
	assert_eq(inst.normal_labels[0].get_child(0).text, text)

	pos = Vector2(-100, -100)
	text = "HelloWorld"
	inst._create_label_node(pos, text)
	assert_eq(len(inst.normal_labels), 2)
	assert_eq(inst.normal_labels[1].position, pos)
	assert_eq(inst.normal_labels[1].get_child(0).text, text)
