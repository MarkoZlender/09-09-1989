extends Node

func _on_fighting_state_physics_processing(_delta: float) -> void:
	if owner.current_state == EnemyState.State.DEAD:
		%StateChart.send_event("dead")
		return

	if owner.current_state == EnemyState.State.HURT:
		%StateChart.send_event("hurt")
		return

	if owner.current_state == EnemyState.State.AGGROED:
		%StateChart.send_event("player_undetected")
		return

