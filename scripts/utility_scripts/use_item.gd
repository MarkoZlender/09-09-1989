extends RefCounted

static func use(item: InventoryItem) -> void:
	item.set_property("stack_size", item.get_property("stack_size") - 1)
	print("Using resource", item.get_property("stack_size"))
