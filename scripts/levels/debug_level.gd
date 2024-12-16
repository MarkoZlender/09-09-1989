extends Node3D

@export var player_data: PlayerData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var saveable_objects = get_tree().get_nodes_in_group("saveable")
	# get resources from saveable objects
	var resources = []
	for obj in saveable_objects:
		var properties = obj.get_property_list()
		for property in properties:
			if property.class_name == &"ItemData":
				#print(property)
				var resource = obj.get(property.name)
				resources.append(resource)
		# var resource = obj.get("item_data")
		# resources.append(resource)
	# save resources
	#print(resources)
	#SaveManager.save_data(1, get_tree().current_scene.scene_file_path, resources)


	# # load resources
	var reconstructed_data: Dictionary = SaveManager.load_data(SaveManager.SAVE_FILE_NAME_1)

	# Iterate over the reconstructed data
	for level_scene_path in reconstructed_data.keys():
		var resources_reconstructed = reconstructed_data[level_scene_path]

		# Iterate over each resource in the scene path
		for rid in resources_reconstructed.keys():
			var resource_data: Dictionary = resources_reconstructed[rid]

			# Create a new resource instance for each resource
			var reconstructed_resource = ItemData.new()
			reconstructed_resource.set_scene_unique_id(rid)

			# Set properties on the new resource instance
			for property_name in resource_data.keys():
				var value = resource_data[property_name]

				# Check if the value is a Vector3 stored as a dictionary
				if value is Dictionary and value.has("x") and value.has("y") and value.has("z"):
					reconstructed_resource.set(property_name, Vector3(value["x"], value["y"], value["z"]))
				else:
					reconstructed_resource.set(property_name, value)
					print(value)

			# Assign the reconstructed resource to the corresponding object
			# Use the `rid` to identify which object to assign to
			for obj in saveable_objects: # Match the object using its unique ID
				for property in obj.get_property_list():
					#if obj.get(property.name).resource_scene_unique_id == rid:
					if property.class_name == "ItemData" && obj.get(property.name).resource_scene_unique_id == rid:
						obj.set(property.name, reconstructed_resource)
						break







	# var reconstructed_resource = ItemData.new()
	# reconstructed_resource.set("name", "Cube 55")
	# for property in saveable_objects[0].get_property_list():
	# 	if property.class_name == &"ItemData":
	# 		saveable_objects[1].set(property.name, reconstructed_resource)


	# for obj in saveable_objects:
	# 	var properties = obj.get_property_list()
	# 	for property in properties:
	# 		if property.class_name == &"ItemData":
	# 			print(reconstructed_data[get_path() as String][obj.get(property.name).resource_scene_unique_id])
	# 			print(obj.get(property.name).resource_scene_unique_id)
	# 			obj.set(property.name, reconstructed_data[get_path() as String][obj.get(property.name).resource_scene_unique_id as String])



	# print(self)
	# var player_resource_properties = player_data.get_property_list()
	# var d = {}
	# for prop in player_resource_properties:
	# 	if prop.usage == 4102:
	# 		if prop.type != TYPE_OBJECT:
	# 			if prop.type == TYPE_VECTOR3:
	# 				# separate the vector3 into its components
	# 				d[prop.name] = {
	# 					"x": player_data.get(prop.name).x,
	# 					"y": player_data.get(prop.name).y,
	# 					"z": player_data.get(prop.name).z
	# 				}
	# 			else: 
	# 				d[prop.name] = player_data.get(prop.name)
		
	# print(player_resource_properties)
			
	# print(d)

