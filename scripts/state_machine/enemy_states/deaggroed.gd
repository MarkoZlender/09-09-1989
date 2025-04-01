extends Node

func _on_deaggroed_state_physics_processing(delta:float) -> void:
	owner.deaggroed(delta)
