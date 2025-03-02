class_name SaveManager extends Node

const SAVE_DIR: String = "user://saves/"
# IMPORTANT: change to .res for release
const SAVE_FILE_NAMES: Array = ["save_slot_0.json", "save_slot_1.json", "save_slot_2.json"]

var current_save_slot: int = 0
var fresh_load: bool = true

func _ready() -> void:
	Global.save_manager = self
	_verify_save_directory(SAVE_DIR)

func _verify_save_directory(path: String) -> void:
	DirAccess.make_dir_absolute(path)

# File handling utilities
func read_existing_file(file_path: String) -> String:
	if not FileAccess.file_exists(file_path):
		printerr("File does not exist: ", file_path)
		return ""
	return read_file_as_text(file_path)

func read_file_as_text(file_path: String) -> String:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		printerr("Failed to open file: ", file_path)
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text

# JSON handling utilities
func parse_json_safe(json_string: String, default_data: Dictionary = {}) -> Dictionary:
	if json_string == "":
		printerr("JSON string is empty.")
		return default_data

	var json: JSON = JSON.new()
	var parse_result: int = json.parse(json_string)
	if parse_result != OK:
		printerr("JSON Parse Error: ", json.get_error_message())
		return default_data

	return json.data

# Node handling utilities
func save_savable_nodes(save_nodes: Array, level_data: Dictionary) -> void:
	for node: Node in save_nodes:
		if node.scene_file_path.is_empty():
			printerr("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		if !node.has_method("save"):
			printerr("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		level_data[node.name] = node.call("save")

		for child: Node in node.get_children():
			if child.is_in_group("savable"):
				var object_array: Array = []
				object_array.append(child)
				save_savable_nodes(object_array, level_data)

# func revert_and_reload_savable_nodes(save_nodes: Array, level_data: Dictionary, parent: Node) -> void:
# 	for node: Node in save_nodes:
# 		for group: StringName in node.get_groups():
# 			node.remove_from_group(group)
# 		node.queue_free()

# 	for node_name: String in level_data.keys():
# 		var node_data: Dictionary = level_data[node_name]
# 		var new_object: Node = load(node_data["filename"]).instantiate()
# 		parent.add_child(new_object, true)

# 		if !new_object.has_method("load"):
# 			printerr("persistent node '%s' is missing a load() function, skipped" % new_object.name)
# 			continue

# 		new_object.call("load", node_data)
# 		new_object.add_to_group("savable")

func revert_and_reload_savable_nodes(save_nodes: Array, level_data: Dictionary) -> void:
	# Create a dictionary to map node names to nodes for quick lookup
	var node_map: Dictionary = {}
	for node in save_nodes:
		node_map[node.name] = node

	# Iterate through the saved level data
	for node_name in level_data.keys():
		if node_name in node_map:
			var node = node_map[node_name]
			var node_data: Dictionary = level_data[node_name]

			if !node.has_method("load"):
				printerr("persistent node '%s' is missing a load() function, skipped" % node.name)
				continue

			node.call("load", node_data)
		else:
			printerr("persistent node '%s' not found in the current scene, skipped" % node_name)

func save_game(slot: int) -> void:
	var save_file_path: String = get_save_file_path(slot)
	var save_data: Dictionary = {
		# inventory serialization
		"inventory":Global.inventory.serialize(),
		"current_level":{},
		"player_data":{},
		"level_data":{},
		"globals": Global.serialize()
	}

	save_data = load_existing_save_data(save_file_path, save_data)

	var current_level_name: StringName = get_tree().current_scene.get_node("World3D").get_children()[0].name
	var save_nodes: Array[Node] = get_tree().get_nodes_in_group("savable")
	save_data["level_data"][current_level_name] = {}
	save_data["current_level"] = get_tree().current_scene.get_node("World3D").get_children()[0].get_scene_file_path()

	if save_nodes.size() == 0:
		printerr("No savable nodes found in the current scene.")
		return

	save_savable_nodes(save_nodes, save_data["level_data"][current_level_name])

	var json_string: String = JSON.stringify(save_data, "\t")

	var save_file: FileAccess = FileAccess.open(save_file_path, FileAccess.WRITE)
	if save_file != null:
		save_file.store_line(json_string)
		save_file.close()
	else:
		printerr("Failed to open save file: ", save_file_path)

func load_game(slot: int, save_point: bool) -> void:
	var save_file_path: String = get_save_file_path(slot)
	var json_string: String = read_existing_file(save_file_path)

	if json_string == "":
		printerr("Save file is empty or does not exist, creating new save file.")
		save_game(slot)
		return

	var save_data: Dictionary = parse_json_safe(json_string)
	if save_data.size() == 0:
		printerr("load_game: JSON Parse Error")
		return

	var current_level_name: StringName = get_tree().current_scene.get_node("World3D").get_children()[0].name
	var level_data_exists: bool = save_data.has("level_data") and save_data["level_data"].has(current_level_name)

	if not level_data_exists:
		printerr("No save data for current level. Saving current state.")
		save_game(slot)
		return

	var save_nodes: Array[Node] = get_tree().get_nodes_in_group("savable")
	print("save_nodes: ", save_nodes)
	if !save_point:
		for node: Node in save_nodes:
			if node.name == "Player":
				save_nodes.erase(node)
	revert_and_reload_savable_nodes(save_nodes, save_data["level_data"][current_level_name])
	# inventory deserialization
	if save_data.has("inventory"):
		Global.inventory.deserialize(save_data["inventory"])
	
	if save_data.has("globals"):
		Global.deserialize(save_data["globals"])

func delete_save_file(slot: int) -> void:
	var save_file_path: String = get_save_file_path(slot)
	if not FileAccess.file_exists(save_file_path):
		printerr("Cannot delete save file. Save file does not exist.")
		return

	DirAccess.remove_absolute(save_file_path)

func get_save_files() -> Array:
	var dir: DirAccess = DirAccess.open(SAVE_DIR)
	var save_files: Array = []
	if dir != null:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				push_warning("This is a directory, not a file: " + file_name)
			else:
				save_files.append(file_name)
			file_name = dir.get_next()
		return save_files
	else:
		printerr("An error occurred when trying to access the path: %s\nDirAccess error: %s" % 
				[SAVE_DIR, DirAccess.get_open_error()])
		return []

func get_current_level(slot: int) -> String:
	return get_save_data_field(slot, "current_level")

func get_current_level_name(slot: int) -> String:
	var current_level_path: String = get_save_data_field(slot, "current_level")
	if current_level_path == "":
		return ""
	var current_level_name: String = current_level_path.get_file().get_basename()
	return current_level_name.capitalize()

func get_save_file_path(slot: int) -> String:
	if slot >= 0 and slot < SAVE_FILE_NAMES.size():
		return SAVE_DIR + SAVE_FILE_NAMES[slot]
	return ""

# Helper functions
func load_existing_save_data(file_path: String, default_data: Dictionary) -> Dictionary:
	var json_string: String = read_existing_file(file_path)
	return parse_json_safe(json_string, default_data)

func get_save_data_field(slot: int, field: String) -> String:
	var save_file_path: String = get_save_file_path(slot)
	var json_string: String = read_existing_file(save_file_path)
	var save_data: Dictionary = parse_json_safe(json_string)

	if field in save_data:
		return save_data[field]
	else:
		printerr("%s not found in save data." % field)
		return ""
