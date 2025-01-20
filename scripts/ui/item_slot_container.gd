class_name ItemSlotContainer extends HBoxContainer

signal item_clicked(item_slot: ItemSlotContainer)

@onready var item_icon: TextureRect = %ItemIcon
@onready var quantity_label: Label = %QuantityLabel
@onready var item_button: Button = %ItemButton


func _on_item_button_pressed() -> void:
	item_clicked.emit(self)

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
