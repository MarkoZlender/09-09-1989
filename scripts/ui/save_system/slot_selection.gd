class_name SlotSelection extends Control

@export var show_empty_slots: bool = true

var overwritable: bool = false

@onready var _vslot_container: VBoxContainer = %VSlotContainer
@onready var _slot_buttons: Array[Node] = []
@onready var _warning_dialog: Panel = %WarningDialog
@onready var _menu_cursor: MenuCursor = %MenuCursor

func _ready() -> void:
	_warning_dialog.confirm_delete.connect(_on_confirm_delete)
	_populate_slots()
	for slot_button: Node in _slot_buttons:
		if slot_button.text.find("Empty") == -1:
			_menu_cursor.focus_node = slot_button
			_menu_cursor.refresh_focus()
			break
		

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_delete"):
		Global.save_manager.current_save_slot = _menu_cursor.cursor_index
		if Global.save_manager.get_current_level(_menu_cursor.cursor_index) != "":
			_menu_cursor.freeze()
			_warning_dialog.show()
			_warning_dialog.menu_cursor.unfreeze()
		else:
			return

func _populate_slots() -> void:
	var n_slots: int = 3
	for slot_index: int in range(n_slots):
		var slot_button: Button = preload(Global.SLOT_BUTTON_SCENE).instantiate()
		var save_file_path: String = Global.save_manager.get_save_file_path(slot_index)
		if FileAccess.file_exists(save_file_path):
			var save_data: Dictionary = Global.save_manager.load_existing_save_data(save_file_path, {})
			if save_data.has("current_level"):
				slot_button.text = str(slot_index + 1) + ". " + save_data["current_level"]
			else:
				slot_button.text = str(slot_index + 1) + ". Empty"
		else:
			slot_button.text = str(slot_index + 1) + ". Empty"
		slot_button.slot = slot_index
		_slot_buttons.append(slot_button)
		_vslot_container.add_child(slot_button)

	for slot_button: Node in _slot_buttons:
		slot_button.connect("slot_button_pressed", _on_slot_button_pressed)

func _refresh_slots() -> void:
	for slot_button: Node in _slot_buttons:
		slot_button.queue_free()
	_slot_buttons.clear()
	_populate_slots()


func _on_slot_button_pressed(slot: int) -> void:
	_menu_cursor.freeze()
	_warning_dialog.set_label_text(false)
	Global.save_manager.current_save_slot = slot
	if Global.save_manager.get_current_level(slot) == "":
		# start new game in empty slot
		Global.game_controller.change_3d_scene(Global.STARTING_LEVEL)
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
