extends Node

func _on_aggroed_state_physics_processing(delta:float) -> void:
	if owner.enemy_data.health <= 0:
		%StateChart.send_event("dead")
		return
	owner.aggroed(delta)
	if owner.is_hurt:
		%StateChart.send_event("hurt")
