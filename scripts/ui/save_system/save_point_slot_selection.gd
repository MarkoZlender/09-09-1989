extends NGSlotSelection

func _on_slot_button_pressed(slot: int) -> void:
	Global.save_manager.current_save_slot = slot
	if Global.save_manager.get_current_level(slot) == "":
		Global.save_manager.save_game(slot)
		Global.game_controller.change_gui_scene("")
		get_tree().paused = false
	elif Global.save_manager.get_current_level(slot) != "":
		_warning_dialog.show()
		_warning_dialog.no_button.grab_focus()
	else:
		printerr("SavePointSlotSelection: _on_slot_button_pressed: invalid save file")

func _on_confirm_overwrite(overwrite: bool) -> void:
	if overwrite:
		Global.save_manager.delete_save_file(Global.save_manager.current_save_slot)
		Global.save_manager.save_game(Global.save_manager.current_save_slot)
		Global.game_controller.change_gui_scene("")
		get_tree().paused = false
	else:
		_warning_dialog.hide()
		_slot_buttons[0].grab_focus()
