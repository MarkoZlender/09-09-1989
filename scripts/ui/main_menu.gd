extends Control

@onready var ng_slot_selection_scene: String = "res://scenes/ui/save_system/ng_slot_selection.tscn"
@onready var ld_slot_selection_scene: String = "res://scenes/ui/save_system/ld_slot_selection.tscn"
# @onready var _new_game_button: Button = %NewGameButton

# test credential manager
func _on_new_game_button_pressed() -> void:
	Global.game_controller.change_gui_scene(ng_slot_selection_scene)

func _on_load_game_button_pressed() -> void:
	Global.game_controller.change_gui_scene(ld_slot_selection_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
