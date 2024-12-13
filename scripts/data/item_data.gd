class_name ItemData 
extends Resource

# unique item id
@export var name: String = "Item"
@export var description: String = "An item"

func set_property(property, value):
    for prop in get_property_list():
        if prop.name == property:
            if prop.type == TYPE_VECTOR3:
                set(prop.name, Vector3(value.x, value.y, value.z))
            else:
                set(prop.name, value)
