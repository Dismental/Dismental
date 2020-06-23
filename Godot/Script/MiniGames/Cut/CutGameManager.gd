extends Node2D

const Role = preload("res://Script/Role.gd")

puppet var puppet_mouse = Vector2()

# Constants for the properties of the x-ray vision texture
const supervisor_shadow_width = 800
const supervisor_shadow_height = 600

var supervisor_shadow_scale = 5
var map_sprite
var running = false
var waitForStartingPosition = true
var pointer_node

var finish_rect
var last_y_coordinate

# 0 is on finsishbox
# 1 is clockwise
# -1 is counterclockwise
var finish_state = 0
var player_role
var map_index

onready var game_over_dialog = $Control/GameOverDialog
onready var completed_dialog = $Control/CompletedDialog
onready var supervisor_vision = $"Control/X-rayVision"


# SFX
onready var game_completed_player = $AudioStreamPlayers/GameCompleted
onready var go_signal_player = $AudioStreamPlayers/GoSignal
onready var game_over_player = $AudioStreamPlayers/GameOver

func _ready():
	_adjust_for_difficulties()

	rpc("_on_update_running", true)
	supervisor_vision.visible = true

	var defuser_id = GameState.defusers[GameState.minigame_index]
	var is_defuser = defuser_id == get_tree().get_network_unique_id()
	player_role = Role.DEFUSER if is_defuser else Role.SUPERVISOR

	# Initialize the HeadTracking scene for this user
	var PointerScene = preload("res://Scenes/Tracking/Pointer.tscn")
	var pointer = PointerScene.instance()
	self.add_child(pointer)
	var pointer_control = pointer.get_node(".")
	pointer_control.set_role(pointer.Role.HEADTHROTTLE)
	pointer_node = pointer.get_node("Pointer")
	pointer_control.p_rad = 1
	
	if player_role == Role.DEFUSER:
		_load_map(map_index, false)

		# Turn the x-ray vision OFF for the operator
		supervisor_vision.visible = false
	else:
		_load_map(map_index)
		# Turn the x-ray vision ON for the operator
		supervisor_vision.visible = true
		# Center the x-ray vision
		_supervisor_vision_update(Vector2(OS.get_window_size().x, OS.get_window_size().y))

	_calc_finish_line()


func _process(_delta):
	if running:
		_update_game_state()
		last_y_coordinate = _get_input_pos().y
		
		# Updates the draw function
		update()


func _draw():
	if waitForStartingPosition:
		var start_pos = _calc_start_position()
		start_pos -= $Control/StartCuttingHere.get_size() / 2
		$Control/StartCuttingHere.set_position(start_pos)
		
	if not waitForStartingPosition and running:
		var input_pos = _get_input_pos()
		$LaserPointer.set_position(input_pos - $LaserPointer.get_rect().size / 2)
		$LaserPointer.show()
		
		if len($CuttingLine.points) == 0:
			$CuttingLine.add_point(input_pos)
		# Add input pos to list of past input position
		# If the previous input position wasn't close
		var last_point = $CuttingLine.points[len($CuttingLine.points) - 1]
		if  last_point.distance_to(input_pos) > 15:
			$CuttingLine.add_point(input_pos)

	# Draw current pointer
	var rad = 12
	var col = Color(1, 0, 0) if not _is_input_on_track() and not waitForStartingPosition else Color(1, 0, 0)
	
	draw_circle(_get_input_pos(), rad, col)


func _adjust_for_difficulties():
	if GameState.difficulty == "EASY":
		map_index = 2
	elif GameState.difficulty == "MEDIUM":
		map_index = 1
	elif GameState.difficulty == "HARD":
		map_index = 1


func _supervisor_vision_update(pos):
	var shadow_pos = Vector2(0,0)

	# Handle edge cases if pos is outside the screen
	var x = clamp(pos.x, 0, get_viewport_rect().size.x)
	var y = clamp(pos.y, 0, get_viewport_rect().size.y)
	
	# Position the center of x-ray shadow texture at the 'pos' input location
	shadow_pos.x = x - supervisor_shadow_width * supervisor_shadow_scale / 2.0
	shadow_pos.y = y - supervisor_shadow_height * supervisor_shadow_scale / 2.0

	supervisor_vision.set_position(shadow_pos)


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			# Quits the game
			get_tree().quit()


func _calc_start_position():
	var center_x = finish_rect.position.x + (finish_rect.size.x / 2.0)
	var center_y = finish_rect.position.y + (finish_rect.size.y / 2.0)
	return Vector2(center_x, center_y)


func _calc_finish_line():
	var start_x_ratio = 0.1

	var vp_rect = get_viewport_rect().size
	var sp = Vector2(vp_rect.x * start_x_ratio, vp_rect.y/2)

	# Find min x
	while(_get_map_pixel_color(sp).a > 0):
		sp.x -= 1
	var min_x = sp.x

	sp.x  = vp_rect.x * start_x_ratio

	# Find max x
	while(_get_map_pixel_color(sp).a > 0):
		sp.x += 1
	var max_x = sp.x

	var rect_height = 120
	finish_rect = Rect2(min_x, sp.y - rect_height/2, max_x - min_x, rect_height)


func _update_game_state():
	if waitForStartingPosition:
		if finish_rect.has_point(_get_input_pos()):
			$Control/StartCuttingHere.visible = false
			$LaserPointer.visible = true
			waitForStartingPosition = false
			go_signal_player.play()
	else:
		if player_role == Role.DEFUSER:
			if not _is_input_on_track():
				rpc("_on_game_over")
			else:
				_check_finish()
	# Move the 'vision' of the Supervisor
	if running and not player_role == Role.DEFUSER:
		_supervisor_vision_update(pointer_node.position)


func _check_finish():
	if finish_state == 0:
		if not finish_rect.has_point(_get_input_pos()):
			if _get_input_pos().y < finish_rect.position.y:
				finish_state = 1
			else:
				finish_state = -1
				
	elif finish_state == 1:
		if finish_rect.has_point(_get_input_pos()):
			if last_y_coordinate > finish_rect.end.y:
				_game_completed()
			else:
				finish_state = 0

	elif finish_state == -1:
		if finish_rect.has_point(_get_input_pos()):
			if last_y_coordinate <= finish_rect.position.y:
				_game_completed()
			else:
				finish_state = 0


func _move_input_to_start():
	var start_position_input = _calc_start_position()
	if player_role == Role.DEFUSER:
		Input.warp_mouse_position(start_position_input)


func _load_map(index=null, visible=true):
	# if no index is given -> generate an random index
	map_sprite = $Control/Map
	randomize()
	if not index:
		var map_path = "res://Scenes/Mini Games/Cut/Maps/"
		# Divide by 2 because every map has an import file behind the scenes
		var map_count = Utils._count_files_in_dir(map_path) / 2
		print(map_count)
		index = randi() % map_count + 1

	var map = "res://Scenes/Mini Games/Cut/Maps/Map%s.png" % index
	map_sprite.texture = load(map)
	map_sprite.visible = visible
	$Control/NoCuttingZoneRect.visible = visible
	$Control/MetalPlate.visible = not visible
	$Control/StartCuttingHere.visible = not visible


func _is_input_on_viewport():
	var input_pos = _get_input_pos()
	if input_pos.x >= 0 and input_pos.x <= get_viewport_rect().size.x:
		if input_pos.y >= 0 and input_pos.y <= get_viewport_rect().size.y:
			return true
	return false


func _is_input_on_track():
	if _is_input_on_viewport():
		var pixelcolor = _get_map_pixel_color(_get_input_pos())
		return pixelcolor.a > 0
	return false


func _get_input_pos():
	var cursorpos
	if player_role == Role.DEFUSER:
		cursorpos = pointer_node.position
		rset("puppet_mouse", cursorpos)
	else:
		cursorpos = puppet_mouse
	return cursorpos


func _get_map_pixel_color(pos):
	var vec = pos
	var map_tex = map_sprite.texture.get_data()
	
	map_tex.lock()
	var pixelcolor = map_tex.get_pixelv(vec)
	map_tex.unlock()
	return pixelcolor


func _game_completed():
	rpc("_on_update_running", false)
	rpc("_on_game_completed")


remotesync func _on_update_running(newValue):
	running = newValue


remotesync func _on_game_over():
	running = false
	game_over_player.play()
	yield(get_tree().create_timer(1.0), "timeout")	
	get_tree().get_root().get_node("GameScene").game_over()
	get_parent().call_deferred("remove_child", self)


remotesync func _on_game_completed():
	game_completed_player.play()
	yield(get_tree().create_timer(1.0), "timeout")
	GameState.load_roadmap()
	get_parent().call_deferred("remove_child", self)
