extends "res://addons/gut/test.gd"


func test_turning_soldering_iron_on_off():
	var inst = partial_double('res://Script/MiniGames/DissolveGameManager.gd').new()
	inst.iron_label = double(Label).new()
	var soldering_iron_on = inst.soldering_iron_on
	
	var event = double(InputEventAction).new()
	stub(event, 'is_action_pressed').to_return(true)
	inst._input(event)
	assert_true(soldering_iron_on != inst.soldering_iron_on )
	inst._input(event)
	assert_true(soldering_iron_on == inst.soldering_iron_on )
