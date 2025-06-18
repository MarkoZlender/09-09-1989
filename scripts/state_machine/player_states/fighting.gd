extends Node

func _on_fighting_state_physics_processing(_delta:float) -> void:
	if owner.is_hurt:
		%StateChart.send_event("player_hurt")

	if !owner.is_attacking:
		%StateChart.send_event("player_stopped_fighting")
