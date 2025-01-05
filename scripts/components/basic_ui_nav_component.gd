extends Node

@export_file("*.tscn") var previous_scene: String

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        if previous_scene != "":
            Global.game_controller.change_gui_scene(previous_scene)
        else:
            Global.game_controller.change_gui_scene("", true, false, false)
            get_tree().paused = false
