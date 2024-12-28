extends Control

@onready var ng_slot_selection_scene: String = "res://scenes/ui/ng_slot_selection.tscn"
@onready var ld_slot_selection_scene: String = "res://scenes/ui/ld_slot_selection.tscn"

func _on_new_game_button_pressed() -> void:
	Global.game_controller.change_gui_scene(ng_slot_selection_scene)

func _on_load_game_button_pressed() -> void:
	Global.game_controller.change_gui_scene(ld_slot_selection_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()