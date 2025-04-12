extends Area3D

func _on_body_entered(body:Node3D) -> void:
	if body is Player:
		print("Player entered the area")
		get_tree().call_deferred("reload_current_scene")
