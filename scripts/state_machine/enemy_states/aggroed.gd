extends Node

func _on_aggroed_state_physics_processing(delta:float) -> void:
	if owner.enemy_data.health <= 0:
		%StateChart.send_event("dead")
		return

	if owner.player_detected:
		%StateChart.send_event("player_found")
	
	owner.aggroed(delta)

	if !owner.player_in_range:
		%StateChart.send_event("deaggroed")

	if owner.is_hurt:
		%StateChart.send_event("hurt")
		return

