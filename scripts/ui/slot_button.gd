class_name SlotButton extends Button

@onready var slot_button_group: ButtonGroup = preload("res://scenes/ui/slot_selection_button_group.tres")

func _ready() -> void:
	button_group = slot_button_group
