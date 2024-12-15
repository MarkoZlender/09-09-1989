extends Control

@onready var slot_selection_scene: String = "res://scenes/ui/slot_selection.tscn"

func _on_load_game_button_pressed() -> void:
	get_tree().change_scene_to_file(slot_selection_scene)
