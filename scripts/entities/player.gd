class_name Player extends CharacterBody3D

#signal pick_up_item(item: Node)
#signal hurt(damage: float)

# @export var FORWARD_SPEED = 2.0
# @export var BACK_SPEED = 5.0
# @export var TURN_SPEED = 0.025
# @export var RUN_SPEED = 4.0
# @export var BACK_RUN_SPEED = 3.0

@export var player_data: PlayerData

@export var MOVE_SPEED: float = 2.0
@export var ROTATION_SPEED: float = 3.0

@export var rotation_speed_idle: float = 3.0
@export var rotation_speed_moving: float = 2.0
@export var rotation_speed_aiming: float = 2.0

@export var move_speed_hurt = 1.0

@export var health: int = 100

var direction: float = 0

func _ready():
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		SaveManager.save_game(1)
		print("Saved game")
	elif event.is_action_pressed("load"):
		SaveManager.load_game(1)
		print("Loaded game")

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

func save() -> Dictionary:
	var save_data = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"pos_z" : position.z,
		"rot_x" : rotation.x,
		"rot_y" : rotation.y,
		"rot_z" : rotation.z,
		"current_level" : get_tree().current_scene.get_scene_file_path(),
		"health" : player_data.health,
		"mana" : player_data.mana
	}
	return save_data

func load(data: Dictionary) -> void:
	position = Vector3(data["pos_x"], data["pos_y"], data["pos_z"])
	rotation = Vector3(data["rot_x"], data["rot_y"], data["rot_z"])
	player_data = PlayerData.new()
	player_data.health = data["health"]
	player_data.mana = data["mana"]
