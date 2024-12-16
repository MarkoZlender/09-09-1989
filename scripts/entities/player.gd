class_name Player extends CharacterBody3D

signal pick_up_item(item: Node)
signal hurt(damage: float)

# @export var FORWARD_SPEED = 2.0
# @export var BACK_SPEED = 5.0
# @export var TURN_SPEED = 0.025
# @export var RUN_SPEED = 4.0
# @export var BACK_RUN_SPEED = 3.0

@export var MOVE_SPEED: float = 2.0
@export var ROTATION_SPEED: float = 3.0

@export var rotation_speed_idle: float = 3.0
@export var rotation_speed_moving: float = 2.0
@export var rotation_speed_aiming: float = 2.0

@export var move_speed_hurt = 1.0

var data: PlayerData

var direction: float = 0

func _ready():
	pass
	# SaveManager.load_data(SaveManager.SAVE_DIR + SaveManager.SAVE_FILE_NAME)
	# data = SaveManager.player_data
	# position = data.map_position

func _input(event: InputEvent) -> void:
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



	if event.is_action_pressed("save"):
		SaveManager.save_data(1, get_tree().current_scene.scene_file_path, resources)
	elif event.is_action_pressed("load"):
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

func move(delta: float):
	rotate_player(delta)
	direction = Input.get_axis("move_back", "move_forward")
	velocity = direction * MOVE_SPEED * global_transform.basis.x

	move_and_slide()

func rotate_player(delta: float) -> void:
	var rotation_direction = Input.get_axis("turn_right", "turn_left")
	#print("Rotation speed: ", ROTATION_SPEED)
	if velocity.length() == 0:
		ROTATION_SPEED = rotation_speed_idle
	else:
		ROTATION_SPEED = rotation_speed_moving
	rotation += Vector3(0, rotation_direction * ROTATION_SPEED * delta, 0)
