extends Node

func _on_hurt_state_entered() -> void:
	owner.is_attacking = false

func _on_hurt_state_physics_processing(_delta:float) -> void:
	if !owner.is_hurt:
		%StateChart.send_event("player_recovered")
