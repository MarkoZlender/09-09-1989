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
			printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instantiate()
		print(node_data["parent"])
		get_node(node_data["parent"]).add_child(new_object, true)
		#new_object.name = new_object.name + str(randi())
		
		if !new_object.has_method("load"):
			printerr("persistent node '%s' is missing a save() function, skipped" % new_object.name)
			continue
		
		new_object.call("load", node_data)

		new_object.add_to_group("savable")
		if new_object is Player:
			new_object.add_to_group("player")
	


########################################################################################################################################################
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


func get_save_file_path(slot: int) -> String:
	match slot:
		1:
			return SAVE_DIR + SAVE_FILE_NAME_1
		2:
			return SAVE_DIR + SAVE_FILE_NAME_2
		3:
			return SAVE_DIR + SAVE_FILE_NAME_3
	return ""
