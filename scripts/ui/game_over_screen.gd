extends Control

func _ready() -> void:
	Global.game_controller.change_3d_scene("")

func _on_restart_button_pressed() -> void:
	pass

func _on_quit_button_pressed() -> void:
	Global.game_controller.change_gui_scene(Global.MAIN_MENU_SCENE)
