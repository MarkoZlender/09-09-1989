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
	pass
	# if event.is_action_pressed("save"):
	# 	data.map_position = position
	# 	SaveManager.save_data(SaveManager.SAVE_DIR + SaveManager.SAVE_FILE_NAME, data)
	# elif event.is_action_pressed("load"):
	# 	SaveManager.load_data(SaveManager.SAVE_DIR + SaveManager.SAVE_FILE_NAME)
	# 	position = data.map_position

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
