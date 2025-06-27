extends Node

func _on_idle_state_physics_processing(delta:float) -> void:
	if owner.current_state == PlayerState.State.HURT:
		%StateChart.send_event("player_hurt")

	if owner.current_state == PlayerState.State.MOVING:
		%StateChart.send_event("player_moved")

	if owner.current_state == PlayerState.State.ATTACKING:
		%StateChart.send_event("player_fighting")

	if owner.current_state == PlayerState.State.INTERACTING:
		%StateChart.send_event("player_interacted")

	owner.move(delta)
