extends Node

func _on_moving_state_physics_processing(delta:float) -> void:
	owner.move(delta)
	if !owner.is_moving:
		%StateChart.send_event("player_stopped")
