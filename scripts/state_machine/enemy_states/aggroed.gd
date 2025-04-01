extends Node

func _on_aggroed_state_physics_processing(delta:float) -> void:
	owner.aggroed(delta)
	if owner.stunned:
		%StateChart.send_event("stunned")
