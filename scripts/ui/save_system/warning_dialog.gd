extends Panel

signal confirm_delete(delete: bool)

@onready var yes_button: Button = %YesButton
@onready var no_button: Button = %NoButton
@onready var menu_cursor: MenuCursor = %MenuCursor

func _ready() -> void:
    menu_cursor.freeze()

func _on_yes_button_pressed() -> void:
    confirm_delete.emit(true)
    menu_cursor.freeze()
    hide()

func _on_no_button_pressed() -> void:
    confirm_delete.emit(false)
    menu_cursor.freeze()
    hide()

