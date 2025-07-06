@tool
extends Node3D
@onready var world_env: WorldEnvironment = $WorldEnvironment
@export var removable_objects: Array[Node3D] = []

func _ready() -> void:
    if Engine.is_editor_hint():
        world_env.environment.volumetric_fog_enabled = false
        world_env.environment.glow_enabled = false
    if not Engine.is_editor_hint():
        world_env.environment.volumetric_fog_enabled = true
        world_env.environment.glow_enabled = true
    
    Global.signal_bus.quest_completed.connect(_on_quest_completed)
    for object: Node3D in get_tree().get_nodes_in_group("removable_objects"):
        removable_objects.append(object)

func _on_quest_completed() -> void:
    await Global.signal_bus.clear_to_remove
    for object: Node3D in removable_objects:
        object.queue_free()

