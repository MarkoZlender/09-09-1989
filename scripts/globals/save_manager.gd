extends Node

signal save_game

const SAVE_DIR: String = "user://saves/"
const SAVE_FILE_NAME_1: String = "save_slot_1.json"
const SAVE_FILE_NAME_2: String = "save_slot_2.json"
const SAVE_FILE_NAME_3: String = "save_slot_3.json"
const SECURITY_KEY: String = "P!rTsVAHNGwT5YWh"

func _ready() -> void:
	_verify_save_directory(SAVE_DIR)

func _verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)

func save_data(slot: int) -> void:
	save_game.emit()
	var level_scene_path: NodePath = get_tree().current_scene.scene_file_path
	var saveable_objects = get_tree().get_nodes_in_group("saveable")
	print("Saveable objects: ", saveable_objects)
	var resources_to_save = get_saveable_resources(saveable_objects)
	print("Resources to save: ", resources_to_save)
	var save_file_path = get_save_file_path(slot)
	#var file: FileAccess = FileAccess.open_encrypted_with_pass(save_file_path, FileAccess.WRITE, SECURITY_KEY)
	var file: FileAccess = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file == null:
		printerr(FileAccess.get_open_error())
		return

	var formated_data: Dictionary = {}
	var rid = 0

	for data_resource in resources_to_save:
		rid = data_resource.get_scene_unique_id()
		formated_data[rid] = {}
		for property in data_resource.get_property_list():
			# 4102 is the usage flag for resource script properties
			if property.usage == 4102 && property.type != TYPE_OBJECT:
				match property.type:
					TYPE_VECTOR3:
						formated_data[rid][property.name] = {
							"x": data_resource.get(property.name).x,
							"y": data_resource.get(property.name).y,
							"z": data_resource.get(property.name).z
						}
					_:
						formated_data[rid][property.name] = data_resource.get(property.name)

	var data: Dictionary = {
		"current_level_scene_path": level_scene_path,
		level_scene_path: formated_data
	}

	var json_string: String = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	file = null

func load_data(slot: int):
	var saveable_objects = get_tree().get_nodes_in_group("saveable")
	var reconstructed_data: Dictionary = reconstruct(slot)

	# Iterate over the reconstructed data
	for level_scene_path in reconstructed_data.keys():
		var resources_reconstructed = reconstructed_data[level_scene_path]

		# Iterate over each resource in the scene path
		for rid in resources_reconstructed.keys():
			var resource_data: Dictionary = resources_reconstructed[rid]

			# Create a new resource instance for each resource and set its unique ID to rid of the original resource
			var reconstructed_resource = null
			if reconstructed_resource is ItemData:
				reconstructed_resource = ItemData.new()
			elif reconstructed_resource is PlayerData:
				reconstructed_resource = PlayerData.new()
			
			reconstructed_resource.set_scene_unique_id(rid)

			# Set properties on the new resource instance
			for property_name in resource_data.keys():
				var value = resource_data[property_name]

				# Check if the value is a Vector3 stored as a dictionary
				if value is Dictionary and value.has("x") and value.has("y") and value.has("z"):
					reconstructed_resource.set(property_name, Vector3(value["x"], value["y"], value["z"]))
				else:
					reconstructed_resource.set(property_name, value)

			# Assign the reconstructed resource to the corresponding object
			# Use the `rid` to identify which object to assign to
			for obj in saveable_objects: # Match the object using its unique ID
				for property in obj.get_property_list():
					if (property.class_name == "ItemData" || property.class_name == "PlayerData") && obj.get(property.name).get_scene_unique_id() == rid:
						obj.set(property.name, reconstructed_resource)
						break


########################################################################################################################################################

func reconstruct(slot: int) -> Dictionary:
	var save_file_path: String = get_save_file_path(slot)

	# Open the file for reading
	var file: FileAccess = FileAccess.open(save_file_path, FileAccess.READ)
	if file == null:
		printerr(FileAccess.get_open_error())
		return {}

	if file.eof_reached():
		printerr("Save file is empty or corrupt.")
		file.close()
		return {}

	# Load and parse the JSON data
	var json_string: String = file.get_as_text()
	file.close()
	file = null

	var data: Dictionary = JSON.parse_string(json_string) as Dictionary

	# Reconstruct the data
	var reconstructed_data: Dictionary = {}

	reconstructed_data[get_current_level(save_file_path)] = {}
	var formated_data: Dictionary = data[str(get_current_level(save_file_path))]

	for rid in formated_data.keys():
		var resource_data: Dictionary = formated_data[rid]
		var reconstructed_resource: Dictionary = {}

		for property_name in resource_data.keys():
			var value = resource_data[property_name]
			if value is Dictionary and value.has("x") and value.has("y") and value.has("z"):
				# It's a Vector3, reconstruct as a dictionary
				reconstructed_resource[property_name] = {
					"x": value["x"],
					"y": value["y"],
					"z": value["z"]
				}
			else:
				reconstructed_resource[property_name] = value

		reconstructed_data[get_current_level(save_file_path)][rid] = reconstructed_resource

	return reconstructed_data

########################################################################################################################################################

func get_save_files() -> Array:
	var dir = DirAccess.open(SAVE_DIR)
	var save_files: Array = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				push_warning("This is a directory. not a file: " + file_name)
				#save_files.append(file_name)
			else:
				save_files.append(file_name)
			file_name = dir.get_next()
	else:
		printerr("An error occurred when trying to access the path.")
	return save_files

func get_current_level(slot: String) -> NodePath:
	var save_file_path = slot

	# Open the file for reading
	var file: FileAccess = FileAccess.open(str(save_file_path), FileAccess.READ)
	if file == null:
		printerr(FileAccess.get_open_error())
		return ""

	if file.eof_reached():
		printerr("Save file is empty or corrupt.")
		file.close()
		return ""

	# Load and parse the JSON data
	var json_string: String = file.get_as_text()
	file.close()
	file = null

	var data: Dictionary = JSON.parse_string(json_string) as Dictionary
	
	return data["current_level_scene_path"]


func get_saveable_resources(objects: Array[Node]) -> Array[Variant]:
	var resources = []
	for obj in objects:
		var properties = obj.get_property_list()
		for property in properties:
			if property.class_name == &"ItemData" || property.class_name == &"PlayerData":
				var resource = obj.get(property.name)
				resources.append(resource)
	return resources

func get_save_file_path(slot: int) -> String:
	match slot:
		1:
			return SAVE_DIR + SAVE_FILE_NAME_1
		2:
			return SAVE_DIR + SAVE_FILE_NAME_2
		3:
			return SAVE_DIR + SAVE_FILE_NAME_3
	return ""
