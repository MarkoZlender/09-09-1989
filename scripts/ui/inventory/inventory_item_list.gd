extends Panel

signal inventory_item_activated(item: InventoryItem) ## Emitted when an inventory item has been double-clicked.
signal inventory_item_clicked(item: InventoryItem) ## Emitted when an inventory item has been clicked.
signal inventory_item_selected(item: InventoryItem) ## Emitted when an inventory item has been selected.
signal finished_loading() ## Emitted when the inventory has finished loading.

const _Utils = preload("res://addons/gloot/core/utils.gd")

## Reference to the inventory that is being displayed.
@export var inventory: Inventory = null:
	set(new_inventory):
		if inventory == new_inventory:
			return

		if new_inventory == null:
			_disconnect_inventory_signals()
			inventory = null
			#_clear()
			update_configuration_warnings()
			return

		inventory = new_inventory
		if inventory.is_node_ready():
			_refresh()
		_connect_inventory_signals()
		update_configuration_warnings()

@onready var items: Array[Node] = %VContainer.get_children()
@onready var v_container: VBoxContainer = %VContainer

func _get_configuration_warnings() -> PackedStringArray:
	if !is_instance_valid(inventory):
		return PackedStringArray([
				"This CtrlInventory node has no inventory set. Set the 'inventory' field to be able to " \
				+ "display its contents."])
	return PackedStringArray()

func _connect_inventory_signals() -> void:
	if !inventory.is_node_ready():
		_Utils.safe_connect(inventory.ready, _refresh)
	inventory.protoset_changed.connect(_refresh)
	inventory.item_property_changed.connect(_on_item_property_changed)
	inventory.item_added.connect(_on_item_manipulated)
	inventory.item_removed.connect(_on_item_manipulated)
	inventory.item_moved.connect(_on_item_manipulated)

func _disconnect_inventory_signals() -> void:
	_Utils.safe_disconnect(inventory.ready, _refresh)
	inventory.protoset_changed.disconnect(_refresh)
	inventory.item_property_changed.disconnect(_on_item_property_changed)
	inventory.item_added.disconnect(_on_item_manipulated)
	inventory.item_removed.disconnect(_on_item_manipulated)
	inventory.item_moved.disconnect(_on_item_manipulated)

func _on_item_property_changed(item: InventoryItem, property: String) -> void:
	if property == InventoryItem._KEY_NAME || property == Inventory._KEY_STACK_SIZE:
		set_item_text(inventory.get_item_index(item), _get_item_title(item))
	if property == InventoryItem._KEY_IMAGE:
		set_item_icon(inventory.get_item_index(item), item.get_texture())


func _on_item_manipulated(item: InventoryItem) -> void:
	_refresh()

func _ready() -> void:
	#set_process(true)
	for item: Node in items:
		item.item_clicked.connect(_on_list_item_clicked)
		#item_selected.connect(_on_list_item_selected)
	inventory = Global.inventory
	_refresh()
	finished_loading.emit()
	# var loaded = preload("res://scenes/ui/menu_cursor.tscn")
	# var instance = loaded.instantiate()
	# add_child(instance)
	# instance.menu_parent_path = NodePath(%VContainer.get_path())
	# for item in v_container.get_children():
	# 	item.focus_mode = FOCUS_NONE


func _on_list_item_activated(index: int) -> void:
	inventory_item_activated.emit(_get_inventory_item(index))


# func _on_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
# 	inventory_item_clicked.emit(_get_inventory_item(index), at_position, mouse_button_index)

func _on_list_item_clicked(index: int) -> void:
	inventory_item_clicked.emit(_get_inventory_item(index))



func _on_list_item_selected(index: int) -> void:
	inventory_item_selected.emit(_get_inventory_item(index))


# ## Returns the selected inventory item. If multiple items are selected, it returns the first one.
# func get_selected_inventory_item() -> InventoryItem:
# 	if get_selected_items().is_empty():
# 		return null

# 	return _get_inventory_item(get_selected_items()[0])


# ## Returns an array of selected inventory items.
# func get_selected_inventory_items() -> Array[InventoryItem]:
# 	var result: Array[InventoryItem]
# 	var indexes = get_selected_items()
# 	for i in indexes:
# 		result.append(_get_inventory_item(i))
# 	return result


func _get_inventory_item(index: int) -> InventoryItem:
	assert(index >= 0)
	assert(index < inventory.get_item_count())
	# return items[index].get_item_metadata()
	print(inventory.get_items()[index].get_property("name") + " " + str(index))
	return inventory.get_items()[index]


func _refresh() -> void:
	_clear()
	_populate()


func _clear() -> void:
	for item: Node in items:
		item.queue_free()
	items.clear()


func _populate() -> void:
	if inventory == null:
		return

	for item: InventoryItem in inventory.get_items():
		var texture: Texture2D = item.get_texture()
		add_item(_get_item_title(item), item.get_stack_size(), texture)
		#item.set_item_metadata(inventory.get_item_count() - 1)


func _get_item_title(item: InventoryItem) -> String:
	if item == null:
		return ""

	var title: String = item.get_title()
	var stack_size: int = item.get_stack_size()
	if stack_size > 1:
		title = "%s" % title

	return title


## Deselects all selected inventory items.
# func deselect_inventory_items() -> void:
# 	deselect_all()


## Selects the given inventory item.
# func select_inventory_item(item: InventoryItem) -> void:
# 	deselect_all()
# 	for index in item_count:
# 		if get_item_metadata(index) != item:
# 			continue
# 		select(index)
# 		return

func set_item_text(index: int, text: String) -> void:
	if index >= 0 and index < items.size():
		items[index].set_item_text(text)
	else:
		print("Index out of bounds: ", index)

func set_item_quantity(index: int, quantity: int) -> void:
	if index >= 0 and index < items.size():
		items[index].set_quantity_text(str(quantity))
	else:
		print("Index out of bounds: ", index)

func set_item_icon(index: int, texture: Texture) -> void:
	if index >= 0 and index < items.size():
		items[index].set_icon(texture)
	else:
		print("Index out of bounds: ", index)

func add_item(text: String, quantity: int, texture: Texture) -> void:
	var scene: Resource = preload("res://scenes/ui/inventory/item_slot_container.tscn")
	var item: Node = scene.instantiate()
	v_container.add_child(item)
	items.append(item)  # Add the new item to the items array

	var index: int = items.size() - 1  # Get the index of the newly added item
	set_item_text(index, text)
	set_item_quantity(index, quantity)
	set_item_icon(index, texture)

	item.item_clicked.connect(_on_list_item_clicked)

func get_item_slot_count() -> int:
	return items.size()
