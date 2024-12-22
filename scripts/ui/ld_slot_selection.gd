extends Control

signal slot_selected(slot: int)

const slot_button_scene: String = "res://scenes/ui/slot_button.tscn"

@onready var main_menu_scene: String = "res://scenes/ui/main_menu.tscn"
@onready var vslot_container: VBoxContainer = $VSlotContainer
@onready var save_buttons: Array = []

func _ready() -> void:
	var save_files = SaveManager.get_save_files()
	print(save_files)
	var n_save_files = save_files.size()
	for save_file_index in range(n_save_files):
		print("Save file index: ", save_file_index)
		var save_button = preload(slot_button_scene).instantiate()
		save_button.text = SaveManager.get_current_level(save_file_index)
		save_button.slot = save_file_index
		save_buttons.append(save_button)
		vslot_container.add_child(save_button)
	for save_button in save_buttons:
		save_button.connect("slot_button_pressed", _on_slot_button_pressed)


func _on_slot_button_pressed(slot: int) -> void:
	print("Slot button pressed: ", slot)
	get_tree().change_scene_to_file(SaveManager.get_current_level(slot))

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene)
