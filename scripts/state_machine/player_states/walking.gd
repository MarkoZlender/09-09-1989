extends PlayerState

@warning_ignore("unused_parameter")
func enter(previous_state_path: String, data := {}) -> void:
	#print("Entering walking state")
	pass

func physics_update(delta: float) -> void:
	player.move(delta)
	
	if is_equal_approx(player.velocity.length(), 0.0):
		finished.emit(IDLE)