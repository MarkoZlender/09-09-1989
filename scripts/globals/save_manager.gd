class_name SaveManager extends Node

const SAVE_DIR: String = "user://saves/"
# IMPORTANT: change to .res for relesase
const SAVE_FILE_NAME_0: String = "save_slot_0.json"
const SAVE_FILE_NAME_1: String = "save_slot_1.json"
const SAVE_FILE_NAME_2: String = "save_slot_2.json"
const SAVE_FILE_NAME_3: String = "save_slot_3.json"
const SAVE_FILE_NAME_4: String = "save_slot_4.json"
const SAVE_FILE_NAME_5: String = "save_slot_5.json"
const SAVE_FILE_NAME_6: String = "save_slot_6.json"
const SAVE_FILE_NAME_7: String = "save_slot_7.json"
const SAVE_FILE_NAME_8: String = "save_slot_8.json"
const SAVE_FILE_NAME_9: String = "save_slot_9.json"

var current_save_slot: int = 0

func _ready() -> void:
	Global.save_manager = self
	_verify_save_directory(SAVE_DIR)

func _verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)

# func save_game(slot: int) -> void:
# 	saving.emit()
# 	var save_file = FileAccess.open(get_save_file_path(slot), FileAccess.WRITE)
# 	if save_file == null:
# 		printerr("Failed to open save file: ", get_save_file_path(slot))
# 		return

# 	var save_nodes = get_tree().get_nodes_in_group("savable")
# 	var save_data = {
# 		"player_data": {},
# 		"level_data": {}
# 	}

# 	for node in save_nodes:
# 		# Check the node is an instanced scene so it can be instanced again during load.
# 		if node.scene_file_path.is_empty():
# 			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
# 			continue

# 		# Check the node has a save function.
# 		if !node.has_method("save"):
# 			print("persistent node '%s' is missing a save() function, skipped" % node.name)
# 			continue

# 		# Call the node's save function.
# 		var node_data: Dictionary = node.call("save")
# 		print(node_data)

# 		# Categorize the data into player data or level data.
# 		if node is Player:
# 			save_data["player_data"] = node_data
# 		else:
# 			var level_name = node.get_parent().name
# 			if not save_data["level_data"].has(level_name):
# 				save_data["level_data"][level_name] = {}
# 			save_data["level_data"][level_name][node.name] = node_data

# 	# Convert the save data dictionary to a JSON string with indents.
# 	var json_string = JSON.stringify(save_data, "\t")

# 	# Store the formatted JSON string in the save file.
# 	save_file.store_line(json_string)
# 	save_file.close()


func save_game(slot: int) -> void:
	var save_file_path = get_save_file_path(slot)
	var save_data = {
		"current_level":{}, #get_tree().current_scene.get_node("World3D").get_children()[0].get_scene_file_path(),
		"player_data": {},
		"level_data": {}
	}

	# Load existing save data if it exists
	if FileAccess.file_exists(save_file_path):
		var save_file_check = FileAccess.open(save_file_path, FileAccess.READ)
		if save_file_check != null:
			var json_string_parse = save_file_check.get_as_text()
			save_file_check.close()

			var json = JSON.new()
			var parse_result = json.parse(json_string_parse)
			if parse_result == OK:
				save_data = json.data
			else:
				printerr("JSON Parse Error: ", json.get_error_message())

	# Update player data
	# var player = get_tree().get_nodes_in_group("player")[0]
	# if player:
	# 	var player_data = player.call("save")
	# 	save_data["player_data"] = player_data

	# Update level data for the current level
	var current_level_name = get_tree().current_scene.get_node("World3D").get_children()[0].name
	var save_nodes = get_tree().get_nodes_in_group("savable")
	#if not save_data["level_data"].has(current_level_name):
	save_data["level_data"][current_level_name] = {}
	save_data["current_level"] = get_tree().current_scene.get_node("World3D").get_children()[0].get_scene_file_path()

	for node in save_nodes:
		if node.scene_file_path.is_empty():
			printerr("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			printerr("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data: Dictionary = node.call("save")
		save_data["level_data"][current_level_name][node.name] = node_data

	# Convert the save data dictionary to a JSON string with indents.
	var json_string = JSON.stringify(save_data, "\t")

	# Store the formatted JSON string in the save file.
	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if save_file != null:
		save_file.store_line(json_string)
		save_file.close()
	else:
		printerr("Failed to open save file: ", save_file_path)



func load_game(slot: int):
	if not FileAccess.file_exists(get_save_file_path(slot)):
		printerr("Save file does not exist, creating new save file.")
		save_game(slot)
		return

	# Load the file line by line and accumulate the JSON string.
	var save_file = FileAccess.open(get_save_file_path(slot), FileAccess.READ)
	if save_file == null:
		printerr("Failed to open save file: ", get_save_file_path(slot))
		return

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

	# Check if there is save data for the player or the current level.
	#var player_data_exists = save_data.has("player_data")
	var current_level_name = get_tree().current_scene.get_node("World3D").get_children()[0].name
	var level_data_exists = save_data.has("level_data") and save_data["level_data"].has(current_level_name)

	if not level_data_exists:
		printerr("No save data for current level. Saving current state.")
		save_game(slot)
		return


	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("savable")
	for i in save_nodes:
		for group in i.get_groups():
			i.remove_from_group(group)
		i.queue_free()

	# Reconstruct the player data.
	# if player_data_exists:
	# 	var player_data = save_data["player_data"]
	# 	var player_scene = load(player_data["filename"])
	# 	if player_scene:
	# 		var player = player_scene.instantiate()
	# 		get_node(get_tree().current_scene.get_path()).add_child(player, true)
			
	# 		if player.has_method("load"):
	# 			player.call("load", player_data)
	# 			player.add_to_group("savable")
	# 			player.add_to_group("player")
	# 		else:
	# 			printerr("Player node is missing a load() function, skipped")

	# Reconstruct the level data for the current level.
	if level_data_exists:
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
	
	var json_string = save_file.get_as_text() # Read the first line to get the current level
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

func get_current_save_slot() -> int:
	return current_save_slot

func set_current_save_slot(slot: int) -> void:
	current_save_slot = slot

func get_save_file_path(slot: int) -> String:
	match slot:
		0:
			return SAVE_DIR + SAVE_FILE_NAME_0
		1:
			return SAVE_DIR + SAVE_FILE_NAME_1
		2:
			return SAVE_DIR + SAVE_FILE_NAME_2
		3:
			return SAVE_DIR + SAVE_FILE_NAME_3
		4:
			return SAVE_DIR + SAVE_FILE_NAME_4
		5:
			return SAVE_DIR + SAVE_FILE_NAME_5
		6:
			return SAVE_DIR + SAVE_FILE_NAME_6
		7:
			return SAVE_DIR + SAVE_FILE_NAME_7
		8:
			return SAVE_DIR + SAVE_FILE_NAME_8
		9:
			return SAVE_DIR + SAVE_FILE_NAME_9
	return ""
