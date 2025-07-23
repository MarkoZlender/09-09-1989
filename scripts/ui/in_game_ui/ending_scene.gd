extends Control

func _ready() -> void:
	await Global.wait(7)
	Global.game_controller.change_gui_scene(Global.MAIN_MENU_SCENE)
	for node: Node in get_tree().get_root().get_children():
		if node is Decal || node is CollectibleRigidBody3D:
			node.queue_free()
