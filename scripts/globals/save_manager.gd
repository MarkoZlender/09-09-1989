extends Node

#@export var data: PlayerData = PlayerData.new()

const SAVE_DIR: String = "user://saves/"
const SAVE_FILE_NAME_1: String = "save_slot_1.json"
const SAVE_FILE_NAME_2: String = "save_slot_2.json"
const SAVE_FILE_NAME_3: String = "save_slot_3.json"
const SECURITY_KEY: String = "P!rTsVAHNGwT5YWh"

var player_data: PlayerData = PlayerData.new()

func _ready() -> void:
	_verify_save_directory(SAVE_DIR)

func _verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)

func save_data(slot: int, level_scene_path: NodePath, data_to_save: Array):
	print(data_to_save)
	var save_file_path = func():
		match slot:
			1:
				return SAVE_DIR + SAVE_FILE_NAME_1
			2:
				return SAVE_DIR + SAVE_FILE_NAME_2
			3:
				return SAVE_DIR + SAVE_FILE_NAME_3

	#var file: FileAccess = FileAccess.open_encrypted_with_pass(save_file_path, FileAccess.WRITE, SECURITY_KEY)
	var file: FileAccess = FileAccess.open(save_file_path.call(), FileAccess.WRITE)
	if file == null:
		printerr(FileAccess.get_open_error())
		return

	
	var formated_data: Dictionary = {}
	var rid = 0

	for data_resource in data_to_save:
		rid = data_resource.resource_scene_unique_id
		print(rid)
		formated_data[rid] = {}
		for property in data_resource.get_property_list():
			# 4102 is the usage flag for resource script properties
			if property.usage == 4102 && property.type != TYPE_OBJECT:
				match property.type:
					TYPE_VECTOR3:
						formated_data[data_resource.get_rid()][property.name] = {
							"x": data_resource.get(property.name).x,
							"y": data_resource.get(property.name).y,
							"z": data_resource.get(property.name).z
						}
					_:
						formated_data[rid][property.name] = data_resource.get(property.name)

	var data: Dictionary = {
		level_scene_path: formated_data
	}

	var json_string: String = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	file = null

func load_data(path: String):
	if FileAccess.file_exists(path):
		var file: FileAccess = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECURITY_KEY)
		if file == null:
			printerr(FileAccess.get_open_error())
			return
		
		var content: String = file.get_as_text()
		file.close()

		var data = JSON.parse_string(content)
		if data == null:
			printerr("Cannot parse %s as a json_string: (%s)" % [path, content])
			return

		#TODO - Create either a separate function for this or create a function inside
		#       each object that needs to be saved that get the list of all the properties
		#       that need to be saved, so that we can iterate through all of the objects that need
		#       to be saved and load them or save them all at once.

		player_data = PlayerData.new()
		#player_data.health = data.player_data.health
		player_data.map_position = Vector3(data.player_data.map_position.x, data.player_data.map_position.y, data.player_data.map_position.z)
		#player_data.gold = data.player_data.gold

	else:
		printerr("Cannot open non-existent file at %s" % [path])
