extends Control

@onready var ng_slot_selection_scene: String = "res://scenes/ui/save_system/ng_slot_selection.tscn"
@onready var ld_slot_selection_scene: String = "res://scenes/ui/save_system/ld_slot_selection.tscn"
# @onready var _new_game_button: Button = %NewGameButton

# test credentia
func _on_new_game_button_pressed() -> void:
	Global.game_controller.change_gui_scene(ng_slot_selection_scene)

func _on_load_game_button_pressed() -> void:
	if Global.save_manager.get_save_files().size() > 0:
		Global.game_controller.change_gui_scene(ld_slot_selection_scene)
	else:
		printerr("Main Menu: _on_load_game_button_pressed: no save files found")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
