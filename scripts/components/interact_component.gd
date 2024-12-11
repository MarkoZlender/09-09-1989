class_name InteractComponent extends Area3D


var interact: Callable = func():
	pass


func _on_body_entered(body:Node3D) -> void:
	InteractionManager.register_area(self)


func _on_body_exited(body:Node3D) -> void:
	InteractionManager.unregister_area(self)
