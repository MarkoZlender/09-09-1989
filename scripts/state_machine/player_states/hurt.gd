extends Node

func _on_hurt_state_entered() -> void:
	#owner.is_attacking = false
	pass

func _on_hurt_state_physics_processing(_delta:float) -> void:
	if owner.current_state != PlayerState.State.HURT:
		%StateChart.send_event("player_recovered")
	
	if owner.current_state == PlayerState.State.INTERACTING:
		%StateChart.send_event("player_interacted")
