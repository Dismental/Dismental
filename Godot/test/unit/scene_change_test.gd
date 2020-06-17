extends "res://addons/gut/test.gd"

func test_main_menu_scene_change():
	var MainMenuPath = 'res://Script/SceneManagers/MainMenuSceneManager.gd'
	var doubled = double(MainMenuPath).new()
	
	stub(doubled, '_on_JoinRoomButton_pressed').to_call_super()
	assert_true(doubled._on_JoinRoomButton_pressed())

	stub(doubled, '_on_CreateRoomButton_pressed').to_call_super()
	assert_true(doubled._on_CreateRoomButton_pressed())
	
	stub(doubled, '_on_SettingsButton_pressed').to_call_super()
	assert_true(doubled._on_SettingsButton_pressed())


func test_join_game_room_scene_change():
	var path = 'res://Script/SceneManagers/JoinGameSceneManager.gd'

	var doubled = double(path).new()

	stub(doubled, '_on_BackButton_pressed').to_call_super()
	assert_true(doubled._on_BackButton_pressed())

	stub(doubled, 'get_input_gameid').to_return("test")	
	stub(doubled, '_on_JoinGameButton_pressed').to_call_super()
	assert_true(doubled._on_JoinGameButton_pressed())


func test_create_game_room_scene_change():
	var path = 'res://Script/SceneManagers/CreateGameRoomManager.gd'

	var doubled = double(path).new()

	stub(doubled, '_on_BackButton_pressed').to_call_super()
	assert_true(doubled._on_BackButton_pressed())

	
	stub(doubled, '_on_CreateRoomButton_pressed').to_call_super()
	assert_true(doubled._on_CreateRoomButton_pressed())


func test_settings_scene_change():
	var path = 'res://Script/SceneManagers/SettingsSceneManager.gd'

	var doubled = double(path).new()

	stub(doubled, '_on_BackButton_pressed').to_call_super()
	assert_true(doubled._on_BackButton_pressed())
