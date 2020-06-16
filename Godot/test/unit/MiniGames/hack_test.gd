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
	
	assert_eq(len(inst.normal_labels), 0)
	
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


func test_remove_one_label():
	var inst = load('res://Script/MiniGames/HackGameManager.gd').new()
	inst.label_nodes = Node.new()
	
	assert_eq(len(inst.normal_labels), 0)
	
	var pos = Vector2(100, 100)
	var text = "Test"
	inst._create_label_node(pos, text)
	assert_eq(len(inst.normal_labels), 1)
	
	inst.normal_labels[0].position.x = inst.screen_width + inst.char_width + 1
	inst._remove_labels()
	assert_eq(len(inst.normal_labels), 0)


func test_remove_multiple_labels():
	var inst = load('res://Script/MiniGames/HackGameManager.gd').new()
	inst.label_nodes = Node.new()
	
	assert_eq(len(inst.normal_labels), 0)
	
	var pos = Vector2(100, 100)
	var text = "Test"
	inst._create_label_node(pos, text)
	assert_eq(len(inst.normal_labels), 1)
	
	inst._create_label_node(pos, text)
	assert_eq(len(inst.normal_labels), 2)
	
	inst._create_label_node(pos, text)
	assert_eq(len(inst.normal_labels), 3)
	
	inst.normal_labels[0].position.x = inst.screen_width + inst.char_width + 1
	inst.normal_labels[1].position.x = inst.screen_width + inst.char_width + 100
	
	var last_node = inst.normal_labels[2]
	
	inst._remove_labels()
	
	assert_eq(len(inst.normal_labels), 1)
	assert_eq(inst.normal_labels[0], last_node)


func test_game_over_called():
	var inst = partial_double('res://Script/MiniGames/HackGameManager.gd').new()
	var Role = preload("res://Script/Role.gd")
	
	inst.player_role = Role.DEFUSER
	inst.online = false
	stub(inst, '_game_over').to_do_nothing()

	inst._on_GameOver_body_entered(Node.new())
	
	assert_call_count(inst, '_game_over', 1)
	assert_call_count(inst, '_game_completed', 0)


func test_password_label():
	var inst = load('res://Script/MiniGames/HackGameManager.gd').new()
	inst.password_label = Label.new()
	inst.password = "TestWord"
	
	inst.collected = 0
	inst._update_password_label()
	assert_eq(inst.password_label.text, "********")

	inst.collected = 1
	inst._update_password_label()
	assert_eq(inst.password_label.text, "T*******")

	inst.collected = 5
	inst._update_password_label()
	assert_eq(inst.password_label.text, "TestW***")

	inst.collected = 8
	inst._update_password_label()
	assert_eq(inst.password_label.text, "TestWord")

	# This should not be possible but test if the game doesn't crash
	inst.collected = 9
	inst._update_password_label()
	assert_eq(inst.password_label.text, "TestWord")
	
	inst.collected = 5
	inst.password = "HelloWorld"
	inst._update_password_label()
	assert_eq(inst.password_label.text, "Hello*****")


func test_collecting_label():
	var inst = load('res://Script/MiniGames/HackGameManager.gd').new()
	inst.online = false
	inst.num_of_collectables = 10
	inst.password_label = Label.new()
	
	var node1 = Node.new()
	var node2 = Node.new()
	inst.collectables = [node1, node2]
	inst.label_nodes = Node.new()
	inst.label_nodes.add_child(node1)
	inst.label_nodes.add_child(node2)
	
	assert_eq(inst.collected, 0)
	inst._on_Bar_body_entered(node1)
	assert_eq(inst.label_nodes.get_child(0), node2)
	assert_eq(inst.collected, 1)
	inst._on_Bar_body_entered(node2)
	assert_eq(inst.collected, 2)


func test_text_update_when_collecting_label():
	var inst = load('res://Script/MiniGames/HackGameManager.gd').new()
	inst.online = false
	inst.num_of_collectables = 10
	inst.password_label = Label.new()
	inst.password = "HelloWorld"
	
	var node1 = Node.new()
	var node2 = Node.new()
	inst.collectables = [node1, node2]
	inst.label_nodes = Node.new()
	inst.label_nodes.add_child(node1)
	inst.label_nodes.add_child(node2)
	
	inst._update_password_label()
	assert_eq(inst.password_label.text, "**********")
	inst._on_Bar_body_entered(node1)
	assert_eq(inst.label_nodes.get_child(0), node2)
	assert_eq(inst.password_label.text, "H*********")
	inst._on_Bar_body_entered(node2)
	assert_eq(inst.password_label.text, "He********")


func test_game_completion_collecting_last_label():
	var inst = partial_double('res://Script/MiniGames/HackGameManager.gd').new()
	stub(inst, '_game_completed').to_do_nothing()
	
	inst.online = false
	inst.num_of_collectables = 2
	inst.password_label = Label.new()
	inst.password = "12"
	
	var node1 = Node.new()
	var node2 = Node.new()
	inst.collectables = [node1, node2]
	inst.label_nodes = Node.new()
	inst.label_nodes.add_child(node1)
	inst.label_nodes.add_child(node2)
	
	inst._on_Bar_body_entered(node1)
	inst._on_Bar_body_entered(node2)
	assert_eq(inst.collected, inst.num_of_collectables)
	assert_eq(inst.collected, 2)
	
	assert_call_count(inst, '_game_completed', 1)
	assert_call_count(inst, '_game_over', 0)
