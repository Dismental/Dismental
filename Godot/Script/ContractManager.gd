extends Node2D

export var contract_is_signed = false

var pointer_start_x = 0.7
var pointer_start_y = 0.5

var scroll_next_offset
var scroll_back_offset = scroll_next_offset

var pointer_node
var pointer_scene
var pointer_control

var panel_contract
var panel_scroll_down
var panel_signhere

var contract_state = 0

var is_scrolling = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var PointerClass = preload("res://Scenes/Tracking/Pointer.tscn")
	pointer_scene = PointerClass.instance()
	self.add_child(pointer_scene)
	pointer_control = pointer_scene.get_node(".")

	var pointer_position = Vector2(pointer_start_x, pointer_start_y)
	var pointer_role = pointer_scene.Role.HEADTHROTTLE
	pointer_control.set_role_and_position(pointer_role, pointer_position)

	pointer_node = pointer_scene.get_node("Pointer")

	panel_contract = get_node("PanelContract")
	panel_scroll_down = get_node("ScrollDown")
	panel_signhere = get_node("PanelContract/SignHere")
	contract_state = 0

	scroll_next_offset = panel_scroll_down.get_rect().size.y
	scroll_back_offset = scroll_next_offset

func _process(_delta):

	if (contract_state == 0):
		var local_in = panel_contract.get_rect()
		if (local_in.has_point(pointer_node.position)):
			if pointer_control.interaction_timer_is_active():
				if pointer_control.interaction_timer_is_finished():
					contract_state = 1
					pointer_control.interaction_timer_deactivate()
			else:
				pointer_control.interaction_timer_activate(1)
		else:
			if pointer_control.interaction_timer_is_active():
				pointer_control.interaction_timer_deactivate()
	elif (contract_state == 1):
		var pos_contract = panel_contract.rect_position
		var pos_y_new = pos_contract.y - 100
		if pos_y_new <= 0:
			pos_y_new = 0
			contract_state = 2
			panel_scroll_down.visible = true
		pos_contract.y = pos_y_new
		panel_contract.rect_position = Vector2(pos_contract)
	elif (contract_state == 2):
		var rect_scroll_down = panel_scroll_down.get_rect()

		if (rect_scroll_down.has_point(pointer_node.position)):
			if pointer_control.interaction_timer_is_active():
				if pointer_control.interaction_timer_is_finished():
					contract_state = 3
					panel_scroll_down.visible = false
					pointer_control.interaction_timer_deactivate()
			else:
				pointer_control.interaction_timer_activate(1)
		else:
			if pointer_control.interaction_timer_is_active():
				pointer_control.interaction_timer_deactivate()
	elif (contract_state == 3):
		var pos_contract = panel_contract.rect_position
		var local_in = panel_contract.get_rect()

		var rect_signhere = panel_signhere.get_rect()
		var pos = rect_signhere.position
		var begin = Vector2(pos.x + local_in.position.x, pos.y + local_in.position.y)
		var end = Vector2(rect_signhere.size.x, rect_signhere.size.y)
		var signhere_rect = Rect2(begin, end)

		if (local_in.has_point(pointer_node.position)):
			var threshold_continue_scroll = get_viewport_rect().size.y - scroll_next_offset
			if (pointer_node.position.y >= threshold_continue_scroll):
				var pos_y_new = pos_contract.y - 100
				var scroll_limit = get_viewport_rect().size.y - panel_contract.get_rect().size.y
				is_scrolling = true
				if pos_y_new <= scroll_limit:
					pos_y_new = scroll_limit
					is_scrolling = false
				pos_contract.y = pos_y_new
				panel_contract.rect_position = Vector2(pos_contract)

			elif (pointer_node.position.y < scroll_back_offset):
				var pos_y_new = pos_contract.y + 100
				is_scrolling = true
				if pos_y_new >= 0:
					pos_y_new = 0
					is_scrolling = false
				pos_contract.y = pos_y_new
				panel_contract.rect_position = Vector2(pos_contract)
		if ((not is_scrolling) and signhere_rect.has_point(pointer_node.position)):
			if pointer_control.interaction_timer_is_active():
				if pointer_control.interaction_timer_is_finished():
					contract_state = 4
					contract_is_signed = true
					pointer_control.interaction_timer_deactivate()
			else:
				pointer_control.interaction_timer_activate(2)
		else:
			if pointer_control.interaction_timer_is_active():
				pointer_control.interaction_timer_deactivate()

	var rect_signhere = panel_signhere.get_rect()

