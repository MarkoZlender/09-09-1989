class_name ItemSlotContainer extends Control

signal item_clicked(index: int)

@onready var item_button: Button = %ItemButton
@onready var item_icon: TextureRect = %ItemIcon
@onready var quantity_label: Label = %QuantityLabel

func _ready() -> void:
	if item_button.disabled:
		quantity_label.modulate = get_theme_color("font_disabled_color", "Button")
		item_icon.modulate = get_theme_color("font_disabled_color", "Button")

func _on_item_button_pressed() -> void:
	item_clicked.emit(get_item_index())

func set_item_text(text: String) -> void:
	item_button.text = text

func set_quantity_text(text: String) -> void:
	quantity_label.text = text

func set_icon(texture: Texture) -> void:
	item_icon.texture = texture

func get_icon():
	return item_icon.texture

func set_item_metadata(metadata: Object) -> void:
	self.metadata = metadata

func get_item_metadata() -> Object:
	return self.metadata

func get_item_index() -> int:
	return get_parent().get_children().find(self)
