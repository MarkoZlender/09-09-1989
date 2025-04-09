extends Area3D

func _on_body_exited(body:Node3D) -> void:
	if body is Player && is_instance_valid(owner):
		%StateChart.send_event("deaggroed")
