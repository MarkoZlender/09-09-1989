extends Control

func _input(event):
	if event.is_action_pressed("inventory"):
		if is_visible():
			hide()
		else:
			show()
