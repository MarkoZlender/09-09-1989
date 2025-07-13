extends Node

func _on_hurt_state_physics_processing(_delta:float) -> void:
	if owner.current_state == EnemyState.State.DEAD:
		%StateChart.send_event("dead")
	
	if owner.current_state == EnemyState.State.ATTACKING:
		%StateChart.send_event("player_found")

	if owner.current_state == EnemyState.State.AGGROED:
		%StateChart.send_event("recovered")



