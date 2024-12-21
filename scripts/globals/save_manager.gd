extends Node

signal saving

const SAVE_DIR: String = "user://saves/"
# IMPORTANT: change to .res for relesase
const SAVE_FILE_NAME_1: String = "save_slot_1.tres"
const SAVE_FILE_NAME_2: String = "save_slot_2.tres"
const SAVE_FILE_NAME_3: String = "save_slot_3.tres"

func _ready() -> void:
	_verify_save_directory(SAVE_DIR)

func _verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)

func save_game(slot: int) -> void:
	saving.emit()
	var save_file = FileAccess.open(get_save_file_path(slot), FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("savable")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")
		print(node_data)

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)
	

func load_game(slot: int):
	if not FileAccess.file_exists(get_save_file_path(slot)):
		printerr("Save file does not exist.")
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("savable")
	for i in save_nodes:
		print("Deleting node: ", i)
		for group in i.get_groups():
			i.remove_from_group(group)
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(get_save_file_path(slot), FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instantiate()
		print(node_data["parent"])
		get_node(node_data["parent"]).add_child(new_object, true)
		
		if !new_object.has_method("load"):
			print("persistent node '%s' is missing a save() function, skipped" % new_object.name)
			continue
		
		new_object.call("load", node_data)

		new_object.add_to_group("savable")
		if new_object is Player:
			new_object.add_to_group("player")
		# new_object.position = Vector3(node_data["pos_x"], node_data["pos_y"], node_data["pos_z"])
		# new_object.rotation = Vector3(node_data["rot_x"], node_data["rot_y"], node_data["rot_z"])

		# # Now we set the remaining variables.
		# for i in node_data.keys():
		# 	if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y" or i == "pos_z" or i == "rot_x" or i == "rot_y" or i == "rot_z":
		# 		continue
		# 	new_object.set(i, node_data[i])
	


########################################################################################################################################################

# func reconstruct(slot: int) -> Dictionary:
# 	var save_file_path: String = get_save_file_path(slot)

# 	# Open the file for reading
# 	var file: FileAccess = FileAccess.open(save_file_path, FileAccess.READ)
# 	if file == null:
# 		printerr(FileAccess.get_open_error())
# 		return {}

# 	if file.eof_reached():
# 		printerr("Save file is empty or corrupt.")
# 		file.close()
# 		return {}

# 	# Load and parse the JSON data
# 	var json_string: String = file.get_as_text()
# 	file.close()
# 	file = null

# 	var data: Dictionary = JSON.parse_string(json_string) as Dictionary

# 	# Reconstruct the data
# 	var reconstructed_data: Dictionary = {}

# 	reconstructed_data[get_current_level(save_file_path)] = {}
# 	var formated_data: Dictionary = data[str(get_current_level(save_file_path))]

# 	for rid in formated_data.keys():
# 		var resource_data: Dictionary = formated_data[rid]
# 		var reconstructed_resource: Dictionary = {}

# 		for property_name in resource_data.keys():
# 			var value = resource_data[property_name]
# 			if value is Dictionary and value.has("x") and value.has("y") and value.has("z"):
# 				# It's a Vector3, reconstruct as a dictionary
# 				reconstructed_resource[property_name] = {
# 					"x": value["x"],
# 					"y": value["y"],
# 					"z": value["z"]
# 				}
# 			else:
# 				reconstructed_resource[property_name] = value

# 		reconstructed_data[get_current_level(save_file_path)][rid] = reconstructed_resource

# 	return reconstructed_data

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

func get_current_level(slot: int) -> NodePath:
	var save_file_path = get_save_file_path(slot)
	if not FileAccess.file_exists(save_file_path):
		printerr("Save file does not exist.")
		return ""
	
	var save_file = FileAccess.open(save_file_path, FileAccess.READ)
	if save_file == null:
		printerr("Failed to open save file: ", save_file_path)
		return ""
	
	var json_string = save_file.get_line() # Read the first line to get the current level
	save_file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		printerr("JSON Parse Error: ", json.get_error_message())
		return ""
	
	var save_data = json.data
	if "current_level" in save_data:
		return save_data["current_level"]
	else:
		printerr("Current level not found in save data.")
		return ""


func get_saveable_resources(objects: Array[Node]) -> Array:
	var resources = []
	for obj in objects:
		if obj.has_method("get_save_data"):
			resources.append(obj.get_save_data())
		else:
			push_warning("Object does not have a get_save_data method: " + str(obj.get_path()))
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
