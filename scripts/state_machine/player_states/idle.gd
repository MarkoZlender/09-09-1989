extends PlayerState

@warning_ignore("unused_parameter")
func enter(previous_state_path: String, data: Dictionary = {}) -> void:
	print("Entering idle state")

func physics_update(delta: float) -> void:
	player.handle_movement_input()
	if player.is_moving:
		finished.emit(WALKING)