extends Node3D

func _unhandled_input(event: InputEvent) -> void:
	if owner.player_data.rotation_controls:
		if event.is_action_pressed("rotate_cam_left"):
			var tween: Tween = get_tree().create_tween()
			tween.connect("finished", _on_tween_finished)
			tween.tween_property(self, "rotation", rotation + Vector3(0, deg_to_rad(-45), 0), 0.3)
			owner.player_data.rotation_controls = false

		elif event.is_action_pressed("rotate_cam_right"):
			var tween: Tween = get_tree().create_tween()
			tween.connect("finished", _on_tween_finished)
			tween.tween_property(self, "rotation", rotation + Vector3(0, deg_to_rad(45), 0), 0.3)
			owner.player_data.rotation_controls = false

func _on_tween_finished() -> void:
	owner.player_data.rotation_controls = true
