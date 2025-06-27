extends Node

var has_been_met: bool = false
var enemy_counter: int = 1
var teeth_counter: int = 5

func _ready() -> void:
	Global.signal_bus.item_rigid_body_collected.connect(_on_item_rigid_body_collected)
	Global.signal_bus.enemy_died.connect(_on_enemy_died)

func _on_item_rigid_body_collected(item: CollectibleRigidBody3D) -> void:
	if item is Tooth:
		teeth_counter -= 1
		if teeth_counter <= 0:
			print("All teeth collected!")
			Global.signal_bus.item_rigid_body_collected.disconnect(_on_item_rigid_body_collected)

func _on_enemy_died(enemy: Node3D) -> void:
	if enemy is Enemy:
		enemy_counter -= 1
		if enemy_counter <= 0:
			#TODO: Handle the case when all enemies are dead
			print("All enemies are dead!")
