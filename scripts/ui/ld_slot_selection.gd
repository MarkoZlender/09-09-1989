extends Control

const slot_button_scene: String = "res://scenes/ui/slot_button.tscn"
const main_menu_scene: String = "res://scenes/ui/main_menu.tscn"

@onready var vslot_container: VBoxContainer = %VSlotContainer
@onready var slot_buttons: Array[SlotButton] = []

func _ready() -> void:
	var save_files: Array = Global.save_manager.get_save_files()
	var n_save_files: int = save_files.size()
	for save_file_index in range(n_save_files):
		var slot_button: SlotButton = preload(slot_button_scene).instantiate()
		slot_button.text = Global.save_manager.get_current_level(save_file_index) + "\n" + save_files[save_file_index]
		slot_button.slot = save_file_index
		slot_buttons.append(slot_button)
		vslot_container.add_child(slot_button)
	for slot_button in slot_buttons:
		slot_button.connect("slot_button_pressed", _on_slot_button_pressed)


func _on_slot_button_pressed(slot: int) -> void:
	Global.save_manager.current_save_slot = slot
	Global.game_controller.change_3d_scene(Global.save_manager.get_current_level(slot))
	#Global.game_controller.change_gui_scene("", false, false)


func _on_back_button_pressed() -> void:
	Global.game_controller.change_gui_scene(main_menu_scene)
