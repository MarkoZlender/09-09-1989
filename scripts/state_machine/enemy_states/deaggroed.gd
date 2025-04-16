extends Node

func _on_deaggroed_state_physics_processing(delta:float) -> void:
	if owner.enemy_data.health <= 0:
		return
	owner.deaggroed(delta)
