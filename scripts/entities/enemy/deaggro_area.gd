extends Area3D

func _on_body_exited(body:Node3D) -> void:
	if body is Player:
		%StateChart.send_event("deaggroed")
