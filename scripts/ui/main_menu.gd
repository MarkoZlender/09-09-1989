extends Control

@onready var slot_selection_scene: String = "res://scenes/ui/save_system/slot_selection.tscn"
# @onready var _new_game_button: Button = %NewGameButton

func _on_new_game_button_pressed() -> void:
	Global.game_controller.change_gui_scene(slot_selection_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
