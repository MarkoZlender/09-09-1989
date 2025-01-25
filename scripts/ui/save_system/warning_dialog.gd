extends Panel

signal confirm_overwrite(overwrite: bool)

@onready var yes_button: Button = %YesButton
@onready var no_button: Button = %NoButton
@onready var menu_cursor = %MenuCursor

func _ready() -> void:
    menu_cursor.freeze()

func _on_yes_button_pressed() -> void:
    confirm_overwrite.emit(true)
    hide()

func _on_no_button_pressed() -> void:
    confirm_overwrite.emit(false)
    hide()

