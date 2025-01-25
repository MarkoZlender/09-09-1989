extends Node

@export var scene_root: Node
@export var element_to_focus: Control

func _ready() -> void:
    scene_root.connect("ready", _on_parent_ready)
    # if element_to_focus != null:
    #     element_to_focus.grab_focus()
    # else:
    #     print("No element to focus on")

func _on_parent_ready() -> void:
    if element_to_focus != null:
        element_to_focus.grab_focus()
    else:
        print("No element to focus on")

