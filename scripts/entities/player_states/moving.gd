extends Node

func _on_moving_state_physics_processing(delta:float) -> void:
	if !owner.is_moving:
		%StateChart.send_event("player_stopped")

	if owner.is_attacking:
		%StateChart.send_event("player_fighting")

	owner.move(delta)
