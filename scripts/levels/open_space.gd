@tool
extends Node3D

@export var removable_objects: Array[Node3D] = []
@onready var world_env: WorldEnvironment = $WorldEnvironment


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	if Engine.is_editor_hint():
		world_env.environment.volumetric_fog_enabled = false
		world_env.environment.glow_enabled = false
	if not Engine.is_editor_hint():
		world_env.environment.volumetric_fog_enabled = true
		world_env.environment.glow_enabled = true
	
	Global.interaction_manager.player = get_tree().get_first_node_in_group("player")

	Global.signal_bus.quest_completed.connect(_on_quest_completed)
	# add objects to remove when quest is completed
	for object: Node3D in get_tree().get_nodes_in_group("removable_objects"):
		removable_objects.append(object)
		print("Added object to removable_objects: ", object.name)
	

func _on_quest_completed() -> void:
	await Global.signal_bus.clear_to_remove
	for object: Node3D in removable_objects:
		object.queue_free()

