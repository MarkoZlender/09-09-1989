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
	if save_file == null:
		printerr("Failed to open save file: ", get_save_file_path(slot))
		return

	var save_nodes = get_tree().get_nodes_in_group("savable")
	var save_data = {
		"player_data": {},
		"level_data": {}
	}

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
		var node_data: Dictionary = node.call("save")
		print(node_data)

		# Categorize the data into player data or level data.
		if node is Player:
			save_data["player_data"] = node_data
		else:
			var level_name = node.get_parent().name
			if not save_data["level_data"].has(level_name):
				save_data["level_data"][level_name] = {}
			save_data["level_data"][level_name][node.name] = node_data

	# Convert the save data dictionary to a JSON string with indents.
	var json_string = JSON.stringify(save_data, "\t")

	# Store the formatted JSON string in the save file.
	save_file.store_line(json_string)
	save_file.close()
	

# func load_game(slot: int):
# 	if not FileAccess.file_exists(get_save_file_path(slot)):
# 		printerr("Save file does not exist.")
# 		return # Error! We don't have a save to load.

# 	# We need to revert the game state so we're not cloning objects
# 	# during loading. This will vary wildly depending on the needs of a
# 	# project, so take care with this step.
# 	# For our example, we will accomplish this by deleting saveable objects.
# 	var save_nodes = get_tree().get_nodes_in_group("savable")
# 	for i in save_nodes:
# 		print("Deleting node: ", i)
# 		for group in i.get_groups():
# 			i.remove_from_group(group)
# 		i.queue_free()

# 	# Load the file line by line and process that dictionary to restore
# 	# the object it represents.
# 	var save_file = FileAccess.open(get_save_file_path(slot), FileAccess.READ)
# 	while save_file.get_position() < save_file.get_length():
# 		var json_string = save_file.get_line()

# 		# Creates the helper class to interact with JSON.
# 		var json = JSON.new()

# 		# Check if there is any error while parsing the JSON string, skip in case of failure.
# 		var parse_result = json.parse(json_string)
# 		if not parse_result == OK:
# 			printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
# 			continue

# 		# Get the data from the JSON object.
# 		var node_data = json.data

# 		# Firstly, we need to create the object and add it to the tree and set its position.
# 		var new_object = load(node_data["filename"]).instantiate()
# 		print(node_data["parent"])
# 		get_node(node_data["parent"]).add_child(new_object, true)
# 		#new_object.name = new_object.name + str(randi())
		
# 		if !new_object.has_method("load"):
# 			printerr("persistent node '%s' is missing a save() function, skipped" % new_object.name)
# 			continue
		
# 		new_object.call("load", node_data)

# 		new_object.add_to_group("savable")
# 		if new_object is Player:
# 			new_object.add_to_group("player")


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

	# Load the file line by line and accumulate the JSON string.
	var save_file = FileAccess.open(get_save_file_path(slot), FileAccess.READ)
	if save_file == null:
		printerr("Failed to open save file: ", get_save_file_path(slot))
		return

	# var json_string = ""
	# while save_file.get_position() < save_file.get_length():
	# 	json_string += save_file.get_line()
	# save_file.close()

	var json_string = save_file.get_as_text()
	save_file.close()

	# Parse the JSON string.
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		printerr("JSON Parse Error: ", json.get_error_message())
		return

	# Get the data from the JSON object.
	var save_data = json.data

	# Reconstruct the player data.
	if save_data.has("player_data"):
		var player_data = save_data["player_data"]
		var player_scene = load(player_data["filename"])
		if player_scene:
			var player = player_scene.instantiate()
			get_node(player_data["parent"]).add_child(player, true)
			
			if player.has_method("load"):
				player.call("load", player_data)
				player.add_to_group("savable")
				player.add_to_group("player")
			else:
				printerr("Player node is missing a load() function, skipped")

	# Reconstruct the level data for the current level.
	var current_level_name = get_tree().current_scene.name
	if save_data.has("level_data") and save_data["level_data"].has(current_level_name):
		var level_data = save_data["level_data"][current_level_name]
		for node_name in level_data.keys():
			var node_data = level_data[node_name]
			var new_object = load(node_data["filename"]).instantiate()
			get_node(node_data["parent"]).add_child(new_object, true)

			if !new_object.has_method("load"):
				printerr("persistent node '%s' is missing a load() function, skipped" % new_object.name)
				continue

			new_object.call("load", node_data)
			new_object.add_to_group("savable")


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
