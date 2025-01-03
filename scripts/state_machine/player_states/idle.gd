extends PlayerState

@warning_ignore("unused_parameter")
func enter(previous_state_path: String, data := {}) -> void:
	#print("Entering idle state")
	player.velocity = Vector3.ZERO

func physics_update(delta: float) -> void:
	player.rotate_player(delta)
	player.direction = Input.get_axis("move_back", "move_forward")
	if player.direction != 0:
		finished.emit(WALKING)
	# if player.velocity.length() > 0:
	# 	finished.emit(WALKING)