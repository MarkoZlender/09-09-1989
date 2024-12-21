extends Control

@onready var ng_slot_selection_scene: String = "res://scenes/ui/ng_slot_selection.tscn"
@onready var ld_slot_selection_scene: String = "res://scenes/ui/ld_slot_selection.tscn"

func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file(ng_slot_selection_scene)

func _on_load_game_button_pressed() -> void:
	get_tree().change_scene_to_file(ld_slot_selection_scene)
