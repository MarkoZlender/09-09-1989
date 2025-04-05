extends Node

func _on_stunned_state_physics_processing(delta:float) -> void:
	#owner.animated_sprite.stop()
	owner.apply_stun_and_knockback(delta)
	if !owner.stunned:
		#owner.animated_sprite.play()
		%StateChart.send_event("recovered")
