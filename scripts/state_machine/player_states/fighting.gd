extends Node

func _on_fighting_state_physics_processing(_delta:float) -> void:
	if owner.current_state == PlayerState.State.HURT:
		%StateChart.send_event("player_hurt")
	
	if owner.current_state == PlayerState.State.INTERACTING:
		%StateChart.send_event("player_interacted")

	if owner.current_state != PlayerState.State.ATTACKING:
		%StateChart.send_event("player_stopped_fighting")
