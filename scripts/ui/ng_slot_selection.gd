extends Control

signal slot_selected(slot: int)

const slot_button_scene: String = "res://scenes/ui/slot_button.tscn"

@onready var main_menu_scene: String = "res://scenes/ui/main_menu.tscn"
@onready var vslot_container: VBoxContainer = $VSlotContainer
@onready var save_button_file_pairs: Dictionary = {}

func _ready() -> void:
	var save_files = SaveManager.get_save_files()
	#print(save_files)
	for save_file in save_files:
		#print(save_file)
		var save_button = preload(slot_button_scene).instantiate()
		save_button.text = save_file
		save_button_file_pairs[save_button] = save_file
		vslot_container.add_child(save_button)


func _on_select_button_pressed() -> void:
	var selected_slot: BaseButton = vslot_container.get_children()[0].button_group.get_pressed_button()
	if selected_slot == null:
		printerr("No slot selected")
		return
	else:
		var save_file = save_button_file_pairs[selected_slot]
		#slot_selected.emit(SaveManager.get_current_level(save_file))
		get_tree().change_scene_to_file(SaveManager.get_current_level(1))

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene)
