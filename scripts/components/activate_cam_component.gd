extends Area3D

var camera

func _ready() -> void:
	camera = get_parent()

func _on_body_entered(body:Node3D) -> void:
	camera.make_current()
