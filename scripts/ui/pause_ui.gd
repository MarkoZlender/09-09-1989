extends Control

var paused: bool = false

func _ready() -> void:
	%MainMenuButton.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		paused = !paused
		get_tree().paused = paused
		if paused:
			show()
			$CanvasLayer.show()
		else:
			hide()
			$CanvasLayer.hide()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	Global.game_controller.change_gui_scene(Global.MAIN_MENU_SCENE)
	Global.game_controller.change_3d_scene("")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
