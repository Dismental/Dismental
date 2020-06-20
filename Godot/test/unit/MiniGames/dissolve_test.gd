extends "res://addons/gut/test.gd"


func test_defuser_state():
	var inst = load('res://Script/MiniGames/DissolveGameManager.gd').new()
	inst.select_player = AudioStreamPlayer.new()
	inst.iron_label = Label.new()
	inst.vacuum_label = Label.new()
	inst.soldering_iron_indicator = ColorRect.new()
	inst.vacuum_indicator = ColorRect.new()
	
	inst._vacuum_entered()
	assert_true(inst.defuse_state == inst.DefuserState.VACUUM )

	inst._vacuum_entered()
	assert_true(inst.defuse_state == inst.DefuserState.OFF)

	inst._soldering_entered()
	assert_true(inst.defuse_state == inst.DefuserState.SOLDERING_IRON)
	
	inst._vacuum_entered()
	assert_true(inst.defuse_state == inst.DefuserState.VACUUM )
