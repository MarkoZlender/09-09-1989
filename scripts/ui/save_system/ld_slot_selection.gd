extends Control

const _slot_button_scene: String = "res://scenes/ui/save_system/slot_button.tscn"
const _main_menu_scene: String = "res://scenes/ui/main_menu.tscn"

@onready var _vslot_container: VBoxContainer = %VSlotContainer
@onready var _slot_buttons: Array[SlotButton] = []

func _ready() -> void:
	var save_files: Array = Global.save_manager.get_save_files()
	var n_save_files: int = save_files.size()
	for save_file_index in range(n_save_files):
		var slot_button: SlotButton = preload(_slot_button_scene).instantiate()
		slot_button.text = str(save_file_index + 1) + ". " + Global.save_manager.get_current_level_name(save_file_index)
		slot_button.slot = save_file_index
		_slot_buttons.append(slot_button)
		_vslot_container.add_child(slot_button)
	for slot_button in _slot_buttons:
		slot_button.connect("slot_button_pressed", _on_slot_button_pressed)

func _on_slot_button_pressed(slot: int) -> void:
	Global.save_manager.current_save_slot = slot
	Global.game_controller.change_3d_scene(Global.save_manager.get_current_level(slot))
