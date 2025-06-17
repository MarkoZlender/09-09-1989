extends Node

func _on_hurt_state_physics_processing(_delta:float) -> void:
	if owner.enemy_data.health <= 0:
		%StateChart.send_event("dead")
