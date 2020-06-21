extends "res://addons/gut/test.gd"

func test_create_mission_button_pressed():
	var MainMenuPath = 'res://Script/SceneManagers/MainMenu/MainMenu.gd'
	var doubled = partial_double(MainMenuPath).new()
	
	stub(doubled, '_on_CreateMissionButton_pressed').to_call_super()
	stub(doubled, 'set_panel_visible').to_do_nothing()
	doubled._on_CreateMissionButton_pressed()
	assert_called(doubled, "set_panel_visible", [$MissionPanel/CreateMissionPanel, true])
	assert_called(doubled, "set_panel_visible", [$MissionPanel/JoinMissionPanel, false])
	assert_called(doubled, "start_scroll_animation", [true])


func test_join_mission_button_pressed():
	var MainMenuPath = 'res://Script/SceneManagers/MainMenu/MainMenu.gd'
	var doubled = double(MainMenuPath).new()

	stub(doubled, '_on_JoinMissionButton_pressed').to_call_super()
	stub(doubled, 'get_create_mission_panel').to_call_super()
	stub(doubled, 'get_join_mission_panel').to_call_super()
	doubled._on_JoinMissionButton_pressed()
	assert_called(doubled, "set_panel_visible", [$MissionPanel/CreateMissionPanel, false])
	assert_called(doubled, "set_panel_visible", [$MissionPanel/JoinMissionPanel, true])
	assert_called(doubled, "start_scroll_animation", [true])


func test_back_button_pressed():
	var MainMenuPath = 'res://Script/SceneManagers/MainMenu/MainMenu.gd'
	var doubled = double(MainMenuPath).new()
	
	stub(doubled, '_on_BackButton_pressed').to_call_super()
	doubled._on_BackButton_pressed()
	assert_called(doubled, "start_scroll_animation", [false])


func test_settings_scene_change():
	var path = 'res://Script/SceneManagers/SettingsSceneManager.gd'

	var doubled = double(path).new()

	stub(doubled, '_on_BackButton_pressed').to_call_super()
	assert_true(doubled._on_BackButton_pressed())
