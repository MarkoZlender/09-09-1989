class_name SlotButton extends Button

signal slot_button_pressed(slot: int)

@export var slot: int = 0
@onready var slot_button_group: ButtonGroup = preload("res://scenes/ui/slot_selection_button_group.tres")

func _ready() -> void:
	button_group = slot_button_group

func _on_pressed() -> void:
	slot_button_pressed.emit(slot)
