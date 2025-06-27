extends Node

func _on_interacting_state_physics_processing(_delta:float) -> void:
	if owner.current_state != PlayerState.State.INTERACTING:
		%StateChart.send_event("player_stopped_interacting")
