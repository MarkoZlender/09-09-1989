class_name ItemData 
extends Resource

# unique item id
@export var name: String = "Item":
    set(value):
        name = value
@export var description: String = "An item"

# func _init() -> void:
#     # set the unique id of the resource to be unique but always the same
#     set_scene_unique_id(get_parent().get_instance_id())

    


func set_property(property, value):
    for prop in get_property_list():
        if prop.name == property:
            if prop.type == TYPE_VECTOR3:
                set(prop.name, Vector3(value.x, value.y, value.z))
            else:
                set(prop.name, value)
