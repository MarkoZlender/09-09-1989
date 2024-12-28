class_name InteractComponent extends Area3D


var interact: Callable = func():
	pass


func _on_body_entered(_body:Node3D) -> void:
	Global.interaction_manager.register_area(self)


func _on_body_exited(_body:Node3D) -> void:
	Global.interaction_manager.unregister_area(self)
