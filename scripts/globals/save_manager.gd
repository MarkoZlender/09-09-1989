extends Node

#@export var data: PlayerData = PlayerData.new()

const SAVE_DIR: String = "user://saves/"
const SAVE_FILE_NAME: String = "save.json"
const SECURITY_KEY: String = "P!rTsVAHNGwT5YWh"

var player_data: PlayerData = PlayerData.new()

func _ready() -> void:
	_verify_save_directory(SAVE_DIR)

func _verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)

func save_data(path: String, data_custom: PlayerData = player_data):
	var file: FileAccess = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SECURITY_KEY)
	if file == null:
		printerr(FileAccess.get_open_error())
		return
	
	var data: Dictionary = {
		"player_data": {
			#"health": data_custom.health,
			"map_position":{
				"x": data_custom.map_position.x,
				"y": data_custom.map_position.y,
				"z": data_custom.map_position.z
			},
			#"gold": data_custom.gold
		}
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
		#       each object that needs to be saved that get the list aof all the properties
		#       that need to be saved, so that we can iterate through all of the objects that need
		#       to be saved and load them or save them all at once.

		player_data = PlayerData.new()
		#player_data.health = data.player_data.health
		player_data.map_position = Vector3(data.player_data.map_position.x, data.player_data.map_position.y, data.player_data.map_position.z)
		#player_data.gold = data.player_data.gold

	else:
		printerr("Cannot open non-existent file at %s" % [path])
