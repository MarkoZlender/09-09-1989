extends Node

var has_been_met: bool = false
var teeth_counter: int = 9

func _ready() -> void:
	Global.signal_bus.item_rigid_body_collected.connect(_on_item_rigid_body_collected)

func _on_item_rigid_body_collected(item: CollectibleRigidBody3D) -> void:
	if item is Tooth:
		teeth_counter -= 1
		if teeth_counter <= 0:
			print("All teeth collected!")
			#Global.signal_bus.item_rigid_body_collected.disconnect(_on_item_rigid_body_collected)
