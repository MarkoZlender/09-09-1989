extends Panel

signal confirm_delete(delete: bool)

@onready var menu_cursor: MenuCursor = %MenuCursor
@onready var warning_label: Label = %WarningText

func _ready() -> void:
	menu_cursor.freeze()

func _on_yes_button_pressed() -> void:
	confirm_delete.emit(true)
	menu_cursor.refresh_focus()
	menu_cursor.freeze()
	hide()

func _on_no_button_pressed() -> void:
	confirm_delete.emit(false)
	menu_cursor.freeze()
	hide()

func set_label_text(overwritable: bool) -> void:
	if overwritable:
		warning_label.text = "Overwrite this save file?"
	elif !overwritable:
		warning_label.text = "Delete this save file?"
