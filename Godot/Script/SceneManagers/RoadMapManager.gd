extends Control

signal wait_time_lobby_over

var is_host = true

var upcoming_minigame = 0

var opening_animating = true
var opening_progress = 0
var blink_progress = 0.0

var instruction_show_progress = 1
var instruction_show_dir_left = false

onready var minigame_previews = [
	$CenterContainer/HBoxContainer/Hack,
	$CenterContainer/HBoxContainer/Cut,
	$CenterContainer/HBoxContainer/Align,
	$CenterContainer/HBoxContainer/Dissolve
]

onready var instruction_panels = [
	$InstructionPanel/HackInstructions,
	$InstructionPanel/CutInstructions,
	$InstructionPanel/AlignInstructions,
	$InstructionPanel/DissolveInstructions
]

onready var countdown_timer = $CountDown
onready var toggle_button_timer = $EnableButtonTimer

onready var instruction_init_pos = self.get_rect().size/2 - $InstructionPanel.get_rect().size / 2
onready var instruction_move = $InstructionPanel.get_rect().size.x / 2


# Called when the node enters the scene tree for the first time.
func _ready():
	is_host = get_tree().is_network_server()
	$StartNextTask.visible = is_host
	$WaitingForHost.visible = not is_host
	init_screen(upcoming_minigame)


func init_screen(upcoming_minigame_index):
	# Start timer
	countdown_timer.start()
	toggle_button_timer.start()

	upcoming_minigame = min(upcoming_minigame_index, len(minigame_previews) - 1)
	for i in range(0, 4):
		if i <= upcoming_minigame:
			minigame_previews[i].modulate = Color(1,1,1,1)
		else:
			minigame_previews[i].modulate = Color(1,1,1,.2)

	opening_animating = true
	opening_progress = 0
	$InstructionPanel.visible = false
	$Line2D.visible = false


func init_instruction_animation():
	for i in instruction_panels:
		i.visible = false
	instruction_panels[upcoming_minigame].visible = true

	instruction_show_dir_left = upcoming_minigame > 1
	instruction_show_progress = 0
	$InstructionPanel.visible = true
	$Line2D.visible = true

	var mg_instruction_label = minigame_previews[upcoming_minigame].get_node("VBoxContainer/LABEL")
	var anim_line_pos = mg_instruction_label.rect_global_position

	if instruction_show_dir_left:
		anim_line_pos += Vector2(0, mg_instruction_label.get_rect().size.y / 2)
	else:
		anim_line_pos += mg_instruction_label.get_rect().size / Vector2(1,2)

	$Line2D.clear_points()
	for i in range(0,4):
		$Line2D.add_point(anim_line_pos)


func draw_instruction_line():
	var start = $Line2D.get_point_position(0)
	var to = ($InstructionPanel.rect_global_position +
		Vector2(0, $InstructionPanel.get_rect().size.y / 2))
	if instruction_show_dir_left:
		to += Vector2($InstructionPanel.get_rect().size.x, 0)
	$Line2D.set_point_position(1, start + Vector2((to.x - start.x) / 2, 0))
	$Line2D.set_point_position(2, start + (to - start) / Vector2(2,1))
	$Line2D.set_point_position(3, to)


func show_next_minigame():
	upcoming_minigame += 1
	init_screen(upcoming_minigame)

func update_progress_bar():
	$ProgressBar.set_size(
		Vector2(self.get_rect().size.x *
			(1.0 - countdown_timer.time_left / countdown_timer.wait_time), 12)
	)

func update_opening_animation(delta):
	if opening_animating and opening_progress < 1:
		opening_progress += delta
		$CenterContainer/HBoxContainer.set(
			"custom_constants/separation",
			(1.0 - pow(1.0 - opening_progress, 6)) * 192 - 96
		)

		if opening_progress >= 1:
			init_instruction_animation()

func update_blinking_animation(delta):
	var upcoming_minigame_node = minigame_previews[upcoming_minigame]
	var upcoming_minigame_img = upcoming_minigame_node.get_node("VBoxContainer/Container/TextureRect")
	var upcoming_minigame_arrow = upcoming_minigame_node.get_node("VBoxContainer/Arrow")

	var alpha_val = 1.0/3 + abs(sin(PI*(blink_progress))) * (2.0/3)
	upcoming_minigame_img.modulate = Color(1,1,1, alpha_val)
	upcoming_minigame_arrow.modulate = Color(1,1,1, alpha_val)

	blink_progress = (blink_progress + delta)
	if blink_progress >= 1:
		blink_progress = 0

func update_instruction_animation(delta):
	if instruction_show_progress < 1:
		instruction_show_progress += delta * .5

		var anim_val = 1.0 - pow(1.0 - instruction_show_progress, 6)
		$InstructionPanel.modulate = Color(1,1,1, anim_val)
		$Line2D.modulate = Color(1,1,1, anim_val)

		var anim_movement = Vector2(instruction_move,0) * anim_val
		if instruction_show_dir_left:
			anim_movement = -anim_movement

		$InstructionPanel.set_position(
			instruction_init_pos + anim_movement
		)

		draw_instruction_line()


func _process(_delta):
	update_progress_bar()

	update_opening_animation(_delta)

	update_blinking_animation(_delta)

	update_instruction_animation(_delta)


func _on_EnableButtonTimer_timeout():
	$StartNextTask.disabled = false
