extends Node3D

func _unhandled_input(event: InputEvent) -> void:
    if owner.rotation_controls:
        if event.is_action_pressed("rotate_cam_left"):
            var tween: Tween = get_tree().create_tween()
            tween.tween_property(self, "rotation", rotation + Vector3(0, deg_to_rad(-45), 0), 0.3)
            #rotation.y += deg_to_rad(-90)

        elif event.is_action_pressed("rotate_cam_right"):
            var tween: Tween = get_tree().create_tween()
            tween.tween_property(self, "rotation", rotation + Vector3(0, deg_to_rad(45), 0), 0.3)
            #rotation.y += deg_to_rad(90)