class_name ItemSlotContainer extends Button

signal item_clicked(index: int)

@onready var item_slot_button: Button = self
@onready var item_name_label: Label = %ItemNameLabel
@onready var item_icon: TextureRect = %ItemIcon
@onready var quantity_label: Label = %QuantityLabel

func _ready() -> void:
	if item_slot_button.disabled:
		quantity_label.modulate = get_theme_color("font_disabled_color", "Button")
		item_icon.modulate = get_theme_color("font_disabled_color", "Button")

func _on_item_slot_button_pressed() -> void:
	item_clicked.emit(get_item_index())

func set_item_text(custom_text: String) -> void:
	item_name_label.text = custom_text

func set_quantity_text(quantity: String) -> void:
	quantity_label.text = quantity

func set_icon(texture: Texture) -> void:
	item_icon.texture = texture

func get_icon() -> Texture2D:
	return item_icon.texture

func set_item_metadata(metadata: Object) -> void:
	self.metadata = metadata

func get_item_metadata() -> Object:
	return self.metadata

func get_item_index() -> int:
	return get_parent().get_children().find(self)
