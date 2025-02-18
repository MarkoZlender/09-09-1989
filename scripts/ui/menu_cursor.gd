# https://gist.github.com/sjvnnings/6b54a962f4c72758b182c49f655ed4e8
# https://www.youtube.com/watch?v=AkhPfCF_2Vg
class_name MenuCursor extends Label

@export var menu_parent_path: NodePath
@export var focus_node: Control
@export var cursor_offset: Vector2

var current_focused_control: Control = null
var cursor_index : int = 0

@onready var menu_parent: Node = get_node(menu_parent_path)

func _ready() -> void:
	await get_parent().ready
	if focus_node != null:
		cursor_index = menu_parent.get_children().find(focus_node)
	else:
		cursor_index = 0
	if menu_parent.has_signal("finished_loading"):
		await menu_parent.finished_loading
	# Check if anim_player is valid
	for menu_item: Node in menu_parent.get_children():
		menu_item.focus_mode = FOCUS_NONE
	menu_parent.get_child(cursor_index).focus_mode = FOCUS_ALL
	current_focused_control = menu_parent.get_child(cursor_index)
	current_focused_control.grab_focus()
	set_cursor()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up", true) || event.is_action_pressed("ui_down", true) || event.is_action_pressed("ui_left", true) || event.is_action_pressed("ui_right", true):
		var child_count: int = menu_parent.get_child_count()
		if menu_parent is VBoxContainer:
			if event.is_action_pressed("ui_up", true):
				cursor_index -= 1
				if cursor_index < 0:
					cursor_index = child_count - 1
			elif event.is_action_pressed("ui_down", true):
				cursor_index += 1
				if cursor_index >= child_count:
					cursor_index = 0
		elif menu_parent is HBoxContainer:
			if event.is_action_pressed("ui_left", true):
				cursor_index -= 1
				if cursor_index < 0:
					cursor_index = child_count - 1
			elif event.is_action_pressed("ui_right", true):
				cursor_index += 1
				if cursor_index >= child_count:
					cursor_index = 0

		current_focused_control.set_focus_mode(FOCUS_NONE)
		current_focused_control = menu_parent.get_child(cursor_index)
		current_focused_control.set_focus_mode(FOCUS_ALL)
		current_focused_control.grab_focus()
		set_cursor()

func refresh_focus() -> void:
	if focus_node != null:
		cursor_index = menu_parent.get_children().find(focus_node)
	else:
		cursor_index = 0
	for menu_item: Node in menu_parent.get_children():
		menu_item.focus_mode = FOCUS_NONE
	menu_parent.get_child(cursor_index).focus_mode = FOCUS_ALL
	current_focused_control = menu_parent.get_child(cursor_index)
	current_focused_control.grab_focus()
	set_cursor()

func _process(_delta: float) -> void:
	if is_instance_valid(current_focused_control):
		#current_focused_control.focus_mode = FOCUS_NONE
		current_focused_control.set_focus_mode(FOCUS_ALL)
		current_focused_control.grab_focus()
		set_cursor()
	else:
		for menu_item: Node in menu_parent.get_children():
			if is_instance_valid(menu_item) && menu_parent.get_children().find(menu_item) == cursor_index:
				menu_item.focus_mode = FOCUS_ALL
				menu_item.grab_focus()
				current_focused_control = menu_item  # Update the current focused control
				cursor_index = menu_parent.get_children().find(current_focused_control)
				set_cursor()
			else:
				menu_item.focus_mode = FOCUS_NONE
		print("MenuCursor: _process: current_focused_control is not valid")
	set_cursor()

func set_cursor() -> void:
	var menu_item: Control = current_focused_control

	if menu_item == null:
		return

	var menu_item_position: Vector2 = menu_item.global_position
	var menu_item_size: Vector2 = menu_item.size

	global_position = Vector2(menu_item_position.x, menu_item_position.y + menu_item_size.y / 2.0) - (size / 2.0) - cursor_offset


func freeze() -> void:
	#anim_player.stop()
	set_process_input(false)
	set_process(false)

func unfreeze() -> void:
	#anim_player.play("eyecandy")
	set_process_input(true)
	set_process(true)
