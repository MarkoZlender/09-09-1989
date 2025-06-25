extends Node

func _on_fighting_state_physics_processing(_delta:float) -> void:
	print("Fighting state processing")
	if owner.is_dead:
		%StateChart.send_event("dead")
		return
	
	if owner.is_hurt:
		%StateChart.send_event("hurt")

	if (!owner.is_attacking && owner.attack_finished) && !owner.player_detected:
		%StateChart.send_event("player_undetected")
