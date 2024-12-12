extends Node3D

@export var player_data: PlayerData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player_resource_properties = player_data.get_property_list()
	var d = {}
	for prop in player_resource_properties:
		if prop.usage == 4102:
			if prop.type != TYPE_OBJECT:
				if prop.type == TYPE_VECTOR3:
					# separate the vector3 into its components
					d[prop.name] = {
						"x": player_data.get(prop.name).x,
						"y": player_data.get(prop.name).y,
						"z": player_data.get(prop.name).z
					}
				else: 
					d[prop.name] = player_data.get(prop.name)
		
	print(player_resource_properties)
			
	print(d)

