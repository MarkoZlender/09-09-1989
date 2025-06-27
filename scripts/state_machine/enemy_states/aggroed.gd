extends Node

func _on_aggroed_state_physics_processing(delta: float) -> void:
	if owner.current_state == EnemyState.State.DEAD:
		%StateChart.send_event("dead")
		return

	if owner.current_state == EnemyState.State.HURT:
		%StateChart.send_event("hurt")
		return

	if owner.current_state == EnemyState.State.ATTACKING:
		%StateChart.send_event("player_found")
		return

	owner.aggroed(delta)

	if owner.current_state == EnemyState.State.DEAGGROED:
		%StateChart.send_event("deaggroed")
		return
