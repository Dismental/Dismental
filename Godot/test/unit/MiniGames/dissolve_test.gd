extends "res://addons/gut/test.gd"


func test_defuser_state():
	var inst = partial_double('res://Script/MiniGames/DissolveGameManager.gd').new()
	inst.iron_label = double(Label).new()
	inst.vacuum_label = double(Label).new()
	inst.soldering_iron_indicator = double(ColorRect).new()
	inst.vacuum_indicator = double(ColorRect).new()
	
	inst._vacuum_entered()
	assert_true(inst.defuse_state == inst.DefuserState.VACUUM )

	inst._vacuum_entered()
	assert_true(inst.defuse_state == inst.DefuserState.OFF)

	inst._soldering_entered()
	assert_true(inst.defuse_state == inst.DefuserState.SOLDERING_IRON)
	
	inst._vacuum_entered()
	assert_true(inst.defuse_state == inst.DefuserState.VACUUM )
