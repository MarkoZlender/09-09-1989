extends Control

signal slot_selected(slot: int)

const slot_button_scene: String = "res://scenes/ui/slot_button.tscn"

@onready var main_menu_scene: String = "res://scenes/ui/main_menu.tscn"
@onready var vslot_container: VBoxContainer = $VSlotContainer
@onready var save_buttons: Array = []

func _ready() -> void:
	var save_files = Global.save_manager.get_save_files()
	print(save_files)
	var n_save_files = save_files.size()
	for save_file_index in range(n_save_files):
		print("Save file index: ", save_file_index)
		var save_button = preload(slot_button_scene).instantiate()
		save_button.text = str(Global.save_manager.get_current_level(save_file_index)) + "\n" + save_files[save_file_index]
		save_button.slot = save_file_index
		save_buttons.append(save_button)
		vslot_container.add_child(save_button)
	for save_button in save_buttons:
		save_button.connect("slot_button_pressed", _on_slot_button_pressed)


func _on_slot_button_pressed(slot: int) -> void:
	print("Slot button pressed: ", slot)
	Global.game_controller.change_3d_scene(Global.save_manager.get_current_level(slot))
	Global.game_controller.change_gui_scene("", false, true)


func _on_back_button_pressed() -> void:
	Global.game_controller.change_gui_scene(main_menu_scene)
