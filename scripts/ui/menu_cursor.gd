# https://gist.github.com/sjvnnings/6b54a962f4c72758b182c49f655ed4e8
# https://www.youtube.com/watch?v=AkhPfCF_2Vg
extends TextureRect

@export var menu_parent_path: NodePath
@export var cursor_offset: Vector2

@onready var menu_parent := get_node(menu_parent_path)
@onready var anim_player: AnimationPlayer = $AnimationPlayer
var current_focused_control: Control = null

var cursor_index : int = 0

func _ready() -> void:
	await get_parent().ready
	# Check if anim_player is valid
	for menu_item in menu_parent.get_children():
		menu_item.focus_mode = FOCUS_NONE
	menu_parent.get_child(cursor_index).focus_mode = FOCUS_ALL
	current_focused_control = menu_parent.get_child(cursor_index)
	current_focused_control.grab_focus()
	set_cursor()

# func _input(event: InputEvent) -> void:
# 	if event.is_action_pressed("ui_up") || event.is_action_pressed("ui_down") || event.is_action_pressed("ui_left") || event.is_action_pressed("ui_right"):
# 		if event.is_action_pressed("ui_up") && cursor_index == 0:
# 			cursor_index = menu_parent.get_child_count() - 2
# 		current_focused_control.focus_mode = FOCUS_NONE
# 		cursor_index += 1
# 		if cursor_index >= menu_parent.get_child_count() && event.is_action_pressed("ui_down"):
# 			cursor_index = 0
# 		elif cursor_index >= menu_parent.get_child_count() && event.is_action_pressed("ui_up"):
# 			cursor_index -= 1
# 		current_focused_control = menu_parent.get_child(cursor_index)
# 		current_focused_control.focus_mode = FOCUS_ALL
# 		menu_parent.get_child(cursor_index).grab_focus()
# 		set_cursor()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		var child_count = menu_parent.get_child_count()
		# Check if current_focused_control is still valid
		if is_instance_valid(current_focused_control):
			current_focused_control.focus_mode = FOCUS_NONE
		else:
			current_focused_control = menu_parent.get_child(0)
		
		if event.is_action_pressed("ui_up"):
			cursor_index -= 1
			if cursor_index < 0:
				cursor_index = child_count - 1
		elif event.is_action_pressed("ui_down"):
			cursor_index += 1
			if cursor_index >= child_count:
				cursor_index = 0
		
		current_focused_control.focus_mode = FOCUS_NONE
		current_focused_control = menu_parent.get_child(cursor_index)
		current_focused_control.focus_mode = FOCUS_ALL
		current_focused_control.grab_focus()
		set_cursor()

func _process(delta: float) -> void:
	set_cursor()
	# if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
	# 	var child_count = menu_parent.get_child_count()
		
	# 	if Input.is_action_just_pressed("ui_up"):
	# 		cursor_index -= 1
	# 		if cursor_index < 0:
	# 			cursor_index = child_count - 1
	# 	elif Input.is_action_just_pressed("ui_down"):
	# 		cursor_index += 1
	# 		if cursor_index >= child_count:
	# 			cursor_index = 0
		
	# 	current_focused_control.focus_mode = FOCUS_NONE
	# 	current_focused_control = menu_parent.get_child(cursor_index)
	# 	current_focused_control.focus_mode = FOCUS_ALL
	# 	current_focused_control.grab_focus()
	# 	set_cursor()


func set_cursor() -> void:
	var menu_item := current_focused_control
	
	if menu_item == null:
		return
	
	var menu_item_position = menu_item.global_position
	var menu_item_size = menu_item.size
	
	global_position = Vector2(menu_item_position.x, menu_item_position.y + menu_item_size.y / 2.0) - (size / 2.0) - cursor_offset
