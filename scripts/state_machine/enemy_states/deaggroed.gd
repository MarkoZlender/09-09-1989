extends Node

func _on_deaggroed_state_physics_processing(delta: float) -> void:
	if owner.current_state == EnemyState.State.DEAD:
		%StateChart.send_event("dead")
		return

	if owner.current_state == EnemyState.State.AGGROED:
		%StateChart.send_event("aggroed")
		return 

	owner.deaggroed(delta)
