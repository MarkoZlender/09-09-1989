extends SlotSelection

func _on_slot_button_pressed(slot: int) -> void:
	_menu_cursor.freeze()
	Global.save_manager.current_save_slot = slot
	if Global.save_manager.get_current_level(slot) == "":
		Global.save_manager.save_game(slot)
		Global.game_controller.change_gui_scene("")
		get_tree().paused = false
	elif Global.save_manager.get_current_level(slot) != "":
		_warning_dialog.show()
		_warning_dialog.menu_cursor.unfreeze()
	else:
		printerr("SavePointSlotSelection: _on_slot_button_pressed: invalid save file")
