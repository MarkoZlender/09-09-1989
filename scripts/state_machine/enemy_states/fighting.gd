extends Node

func _on_fighting_state_physics_processing(delta:float) -> void:
	print("Fighting state processing")
	#owner.aggroed(delta)
	if owner.is_dead:
		%StateChart.send_event("dead")
		return

	if !owner.is_attacking && owner.attack_finished:
		%StateChart.send_event("player_undetected")
