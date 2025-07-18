extends Control

func _ready() -> void:
	$BackButton.grab_focus()

func _on_back_button_pressed() -> void:
	Global.game_controller.change_gui_scene(Global.MAIN_MENU_SCENE)
