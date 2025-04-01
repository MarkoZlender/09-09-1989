extends Node

func _on_stunned_state_physics_processing(delta:float) -> void:
	owner.apply_stun_and_knockback(delta)
	if !owner.stunned:
		%StateChart.send_event("recovered")
