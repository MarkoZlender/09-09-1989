class_name SlotSelection extends Control

const _slot_button_scene: String = "res://scenes/ui/save_system/slot_button.tscn"
const _main_menu_scene: String = "res://scenes/ui/main_menu.tscn"
const _starting_level: String = "res://scenes/levels/debug_level.tscn"

@export var show_empty_slots: bool = true

@onready var _vslot_container: VBoxContainer = %VSlotContainer
@onready var _slot_buttons: Array[Node] = []
@onready var _warning_dialog: Panel = %WarningDialog
@onready var _menu_cursor: MenuCursor = %MenuCursor

func _ready() -> void:
	_warning_dialog.confirm_delete.connect(_on_confirm_delete)
	_populate_slots()

func _populate_slots() -> void:
	var save_files: Array = Global.save_manager.get_save_files()
	var n_save_files: int = save_files.size()
	var n_slots: int = 3
	for save_file_index: int in range(n_slots):
		var slot_button: Node = preload(_slot_button_scene).instantiate()
		if save_file_index < n_save_files:
			slot_button.text = str(save_file_index + 1) + ". " + Global.save_manager.get_current_level_name(save_file_index)
		else:
			slot_button.text = "Empty"
		slot_button.slot = save_file_index
		_slot_buttons.append(slot_button)
		_vslot_container.add_child(slot_button)
	
	_menu_cursor.refresh_focus()

	for slot_button: Node in _slot_buttons:
		slot_button.connect("slot_button_pressed", _on_slot_button_pressed)
	
	

func _refresh_slots() -> void:
	for slot_button: Node in _slot_buttons:
		slot_button.queue_free()
	_slot_buttons.clear()
	_populate_slots()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_delete"):
		Global.save_manager.current_save_slot = _menu_cursor.cursor_index
		_menu_cursor.freeze()
		_warning_dialog.show()
		_warning_dialog.menu_cursor.unfreeze()

func _on_slot_button_pressed(slot: int) -> void:
	_menu_cursor.freeze()
	Global.save_manager.current_save_slot = slot
	if Global.save_manager.get_current_level(slot) == "":
		# start new game in empty slot
		Global.game_controller.change_3d_scene(_starting_level)
	elif Global.save_manager.get_current_level(slot) != "":
		# load game
		Global.game_controller.change_3d_scene(Global.save_manager.get_current_level(slot))
	else:
		printerr("SlotSelection: _on_slot_button_pressed: invalid save file")

func _on_confirm_delete(delete: bool) -> void:
	if delete:
		Global.save_manager.delete_save_file(Global.save_manager.current_save_slot)
		_menu_cursor.unfreeze()
		_refresh_slots()
	else:
		_warning_dialog.hide()
		_menu_cursor.unfreeze()
		
