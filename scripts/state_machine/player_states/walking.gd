extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	print("Entering walking state")

func physics_update(delta: float) -> void:
	player.move(delta)
	
	if is_equal_approx(player.velocity.length(), 0.0):
		finished.emit(IDLE)