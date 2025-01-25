class_name SlotSelection extends Control

const _slot_button_scene: String = "res://scenes/ui/save_system/slot_button.tscn"
const _main_menu_scene: String = "res://scenes/ui/main_menu.tscn"
const _starting_level: String = "res://scenes/levels/debug_level.tscn"

@export var show_empty_slots: bool = true

@onready var _vslot_container: VBoxContainer = %VSlotContainer
@onready var _slot_buttons: Array[Node] = []
@onready var _warning_dialog: Panel = %WarningDialog
@onready var _menu_cursor = %MenuCursor

func _ready() -> void:
	_warning_dialog.confirm_overwrite.connect(_on_confirm_overwrite)
	var save_files: Array = Global.save_manager.get_save_files()
	var n_save_files: int = save_files.size()
	var n_slots: int = 10
	for save_file_index: int in range(n_slots):
		var slot_button: Node = preload(_slot_button_scene).instantiate()
		if save_file_index < n_save_files:
			slot_button.text = str(save_file_index + 1) + ". " + Global.save_manager.get_current_level_name(save_file_index)
			slot_button.slot = save_file_index
			_slot_buttons.append(slot_button)
			_vslot_container.add_child(slot_button)
		elif save_file_index >= n_save_files && show_empty_slots:
			slot_button.text = "Empty"
			slot_button.slot = save_file_index
			_slot_buttons.append(slot_button)
			_vslot_container.add_child(slot_button)
		elif save_file_index >= n_save_files && !show_empty_slots:
			break
		else:
			printerr("SlotSelection: _ready: invalid save file")


	for slot_button: Node in _slot_buttons:
		slot_button.connect("slot_button_pressed", _on_slot_button_pressed)


func _on_slot_button_pressed(slot: int) -> void:
	_menu_cursor.freeze()
	Global.save_manager.current_save_slot = slot
	if Global.save_manager.get_current_level(slot) == "":
		# start new game in empty slot
		Global.game_controller.change_3d_scene(_starting_level)
	elif Global.save_manager.get_current_level(slot) != "" && show_empty_slots:
		# overwrite game for new game
		_warning_dialog.show()
		_warning_dialog.menu_cursor.unfreeze()
		_warning_dialog.no_button.grab_focus()
	elif Global.save_manager.get_current_level(slot) != "" && !show_empty_slots:
		# load game
		Global.game_controller.change_3d_scene(Global.save_manager.get_current_level(slot))
	else:
		printerr("SlotSelection: _on_slot_button_pressed: invalid save file")

func _on_confirm_overwrite(overwrite: bool) -> void:
	if overwrite:
		Global.save_manager.delete_save_file(Global.save_manager.current_save_slot)
		Global.game_controller.change_3d_scene(_starting_level)
	else:
		_warning_dialog.menu_cursor.freeze()
		_warning_dialog.hide()
		_menu_cursor.unfreeze()
		
