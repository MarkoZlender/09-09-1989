extends Control

var paused: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		paused = !paused
		get_tree().paused = paused
		if paused:
			show()
		else:
			hide()
