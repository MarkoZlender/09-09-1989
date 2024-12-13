extends Node3D

@export var item_data_for_cube: ItemData
@export var text: String = "Interact"
@onready var interact_component: InteractComponent = $InteractComponent
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_component.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	print(text)
	# await dialog finished, animation finished, etc.
