extends "res://addons/gut/test.gd"

func test_main_menu_scene_change():
	var MainMenuPath = 'res://Script/SceneManagers/MainMenuSceneManager.gd'

	var doubled = double(MainMenuPath).new()

	stub(doubled, '_on_JoinRoomButton_pressed').to_call_super()
	doubled._on_JoinRoomButton_pressed()
	assert_called(doubled, 'change_scene', ["res://Scenes/JoinGameRoom.tscn"])
	
	stub(doubled, '_on_CreateRoomButton_pressed').to_call_super()
	doubled._on_CreateRoomButton_pressed()
	assert_called(doubled, 'change_scene', ["res://Scenes/CreateGameRoom.tscn"])
	
	stub(doubled, '_on_SettingsButton_pressed').to_call_super()
	doubled._on_SettingsButton_pressed()
	assert_called(doubled, 'change_scene', ["res://Scenes/SettingsScene.tscn"])

func test_join_game_room_scene_change():
	var path = 'res://Script/SceneManagers/JoinGameSceneManager.gd'

	var doubled = double(path).new()

	stub(doubled, '_on_BackButton_pressed').to_call_super()
	doubled._on_BackButton_pressed()
	assert_called(doubled, 'change_scene', ["res://Scenes/MainMenu.tscn"])
	
	stub(doubled, '_on_JoinGameButton_pressed').to_call_super()
	doubled._on_JoinGameButton_pressed()
	assert_called(doubled, 'change_scene', ["res://Scenes/GameRoomPlayer.tscn"])

func test_create_game_room_scene_change():
	var path = 'res://Script/SceneManagers/CreateGameRoomManager.gd'

	var doubled = double(path).new()

	stub(doubled, '_on_BackButton_pressed').to_call_super()
	doubled._on_BackButton_pressed()
	assert_called(doubled, 'change_scene', ["res://Scenes/MainMenu.tscn"])
	
	stub(doubled, '_on_CreateRoomButton_pressed').to_call_super()
	doubled._on_CreateRoomButton_pressed()
	assert_called(doubled, 'change_scene', ["res://Scenes/GameRoomHost.tscn"])
	

func test_settings_scene_change():
	var path = 'res://Script/SceneManagers/SettingsSceneManager.gd'

	var doubled = double(path).new()

	stub(doubled, '_on_BackButton_pressed').to_call_super()
	doubled._on_BackButton_pressed()
	assert_called(doubled, 'change_scene', ["res://Scenes/MainMenu.tscn"])
	
