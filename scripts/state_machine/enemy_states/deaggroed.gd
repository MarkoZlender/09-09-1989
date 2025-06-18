extends Node

func _on_deaggroed_state_physics_processing(delta:float) -> void:
	if owner.enemy_data.health <= 0:
		%StateChart.send_event("dead")
		return

	if owner.is_aggroed:
		%StateChart.send_event("aggroed")
		print("Transitioning to aggroed state")

	owner.deaggroed(delta)
