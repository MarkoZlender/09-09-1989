class_name Player extends Node3D
const TRAVEL_TIME: float = 0.3
# Grid settings
@export var cell_size: Vector3 = Vector3(1, 0, 1)
@export var move_speed: float = 5.0
@export var gridmap: GridMap

enum ROTATION_DIRECTION {
	LEFT,
	RIGHT
}

@onready var camera_rig: Marker3D = %CameraRig
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var grid_position: Vector3= Vector3(0.5, 0, -1.5)
var global_cell_coordinates: Array[Vector3] = []
var tween: Tween
var is_moving: bool= false
var inputs: Dictionary = {
	"move_right": Vector3.RIGHT,
	"move_left": Vector3.LEFT,
	"move_forward": Vector3.FORWARD,
	"move_back": Vector3.BACK
}

func _ready() -> void:
	#self.global_transform.origin = gridmap.map_to_local(Vector3i(0, 1, 0))
	global_position = grid_position
	for cell: Vector3i in gridmap.get_used_cells():
		global_cell_coordinates.append(gridmap.map_to_local(cell))

# func _process(delta: float) -> void:
# 	handle_movement_input()

func handle_movement_input() -> void:
	if tween is Tween and tween.is_running():
		return
	
	var local_forward: Vector3 = -transform.basis.z
	var local_back: Vector3 = transform.basis.z
	var local_left: Vector3 = -transform.basis.x
	var local_right: Vector3 = transform.basis.x

#region forward_back
	# not using switch/match because it is slower in gdscript than if-elif-else statements
	if Input.is_action_pressed("move_forward") && is_position_valid(position + local_forward * cell_size):
		if !animation_player.is_playing():
			move(local_forward)

	elif Input.is_action_pressed("move_back") && is_position_valid(position + local_back * cell_size):
		if !animation_player.is_playing():
			move(local_back)
#endregion

#region strafing
	elif Input.is_action_pressed("strafe_left") && is_position_valid(position + local_left * cell_size):
		if !animation_player.is_playing():
			move(local_left)

	elif Input.is_action_pressed("strafe_right") && is_position_valid(position + local_right * cell_size):
		if !animation_player.is_playing():
			move(local_right)
#endregion

#region left_right
	elif Input.is_action_pressed("move_left") && !Input.is_action_pressed("strafe_left"):
		rotate_player(ROTATION_DIRECTION.LEFT)

	elif Input.is_action_pressed("move_right") && !Input.is_action_pressed("strafe_right"):
		rotate_player(ROTATION_DIRECTION.RIGHT)

	else:
		is_moving = false


func move(direction: Vector3) -> void:
	is_moving = true
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + direction * cell_size, TRAVEL_TIME)
	animation_player.play("headbob")
	#play_footsteps()

func rotate_player(direction: ROTATION_DIRECTION) -> void:
	is_moving = true
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if direction == ROTATION_DIRECTION.LEFT:
		tween.tween_property(self, "transform", transform.rotated_local(Vector3.UP, PI / 2), TRAVEL_TIME)
	elif direction == ROTATION_DIRECTION.RIGHT:
		tween.tween_property(self, "transform", transform.rotated_local(Vector3.UP, -PI / 2), TRAVEL_TIME)


func is_position_valid(pos: Vector3) -> bool:
	var cell: Vector3i = gridmap.local_to_map(pos)
	return gridmap.get_cell_item(cell) != GridMap.INVALID_CELL_ITEM

func save() -> Dictionary:
	var save_data: Dictionary = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : global_position.x, # Vector2 is not supported by JSON
		"pos_y" : global_position.y,
		"pos_z" : global_position.z,
		"rot_x" : rotation.x,
		"rot_y" : rotation.y,
		"rot_z" : rotation.z,
	}
	return save_data

func load(data: Dictionary) -> void:
	global_position = Vector3(data["pos_x"], data["pos_y"], data["pos_z"])
	rotation = Vector3(data["rot_x"], data["rot_y"], data["rot_z"])
