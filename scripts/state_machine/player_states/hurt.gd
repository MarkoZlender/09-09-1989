extends Node

func _on_hurt_state_physics_processing(_delta:float) -> void:
	print("Hurt state processing...")
	owner.is_hurt = false
	if !owner.is_hurt:
		%StateChart.send_event("player_recovered")
