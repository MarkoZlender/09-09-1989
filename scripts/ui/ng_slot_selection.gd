extends Control

const slot_button_scene: String = "res://scenes/ui/slot_button.tscn"

@onready var main_menu_scene: String = "res://scenes/ui/main_menu.tscn"
@onready var vslot_container: VBoxContainer = %VSlotContainer
@onready var save_buttons: Array = []
@onready var warning_dialog: Panel = $WarningDialog
@export_file("*.tscn") var starting_level: String

func _ready() -> void:
	warning_dialog.confirm_overwrite.connect(_on_confirm_overwrite)
	var save_files = Global.save_manager.get_save_files()
	var n_save_files = save_files.size()
	var n_slots = 10
	for save_file_index in range(n_slots):
		var save_button = preload(slot_button_scene).instantiate()
		if save_file_index < n_save_files:
			save_button.text = Global.save_manager.get_current_level(save_file_index) + "\n" + save_files[save_file_index]
		else:
			save_button.text = "Empty"
		save_button.slot = save_file_index
		save_buttons.append(save_button)
		vslot_container.add_child(save_button)
	for save_button in save_buttons:
		save_button.connect("slot_button_pressed", _on_slot_button_pressed)


func _on_slot_button_pressed(slot: int) -> void:
	print("Slot button pressed: ", slot)
	Global.save_manager.set_current_save_slot(slot)
	if Global.save_manager.get_current_level(slot) != "":
		warning_dialog.show()
	elif Global.save_manager.get_current_level(slot) == "":
		Global.game_controller.change_3d_scene(starting_level)
		Global.game_controller.change_gui_scene("")
		return
	else:
		Global.game_controller.change_3d_scene(Global.save_manager.get_current_level(slot))
		Global.game_controller.change_gui_scene("")

func _on_back_button_pressed() -> void:
	Global.game_controller.change_gui_scene(main_menu_scene)

func _on_confirm_overwrite(overwrite: bool) -> void:
	if overwrite:
		Global.save_manager.delete_save_file(Global.save_manager.get_current_save_slot())
		Global.game_controller.change_3d_scene(starting_level)
		Global.game_controller.change_gui_scene("")
	else:
		warning_dialog.hide()
		