extends Control

func _ready() -> void:
    await Global.wait(7)
    Global.game_controller.change_gui_scene(Global.MAIN_MENU_SCENE)