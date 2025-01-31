class_name Player extends CharacterBody3D

# Grid settings
@export var cell_size := Vector3(1, 0, 1)  # Cell size (X, Y, Z)
@export var move_speed := 5.0  # Tween speed
@export var gridmap: GridMap

@onready var camera_rig: Marker3D = %CameraRig

var grid_position := Vector3(0.5, 0, 0.5)
var is_moving := false
var move_queue := []
var current_direction := Vector3.ZERO
var global_cell_coordinates: Array[Vector3] = []
var tween
var inputs = {
	"move_right": Vector3.RIGHT,
	"move_left": Vector3.LEFT,
	"move_forward": Vector3.FORWARD,
	"move_back": Vector3.BACK
}

func _ready():
	camera_rig.top_level = true
	position = grid_position
	for cell in gridmap.get_used_cells():
		global_cell_coordinates.append(gridmap.map_to_local(cell))

func _process(delta: float) -> void:
	# for dir in inputs.keys():
	# 	if Input.is_action_pressed(dir):
	# 		move(dir)
	camera_follows_player()
	if Input.is_action_pressed("move_forward"):
		move("move_forward")
	elif Input.is_action_pressed("move_back"):
		move("move_back")
	elif Input.is_action_pressed("move_left"):
		move("move_left")
	elif Input.is_action_pressed("move_right"):
		move("move_right")
	else:
		$Cynthia/AnimationPlayer.play("Idle")

func camera_follows_player():
	var player_pos = global_position
	camera_rig.global_position = player_pos + Vector3(-5,6,5)

func move(dir):
	match dir:
			"move_right":
				rotation.y = deg_to_rad(0)
			"move_left":
				rotation.y = deg_to_rad(180)
			"move_forward":
				rotation.y = deg_to_rad(90)
			"move_back":
				rotation.y = deg_to_rad(-90)
	
	if is_position_valid(position + inputs[dir]):
		$Cynthia/AnimationPlayer.play("Run")


		var new_position = position + inputs[dir] * cell_size
		

		var tween: Tween = create_tween()
		#tween.set_loops(2)
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.tween_property(self, "position", new_position, 1 / move_speed).set_trans(Tween.TRANS_LINEAR)
		#tween.tween_callback(_on_tween_finished)
		await tween.finished
		grid_position = position / cell_size
		current_direction = Vector3.ZERO

func _on_tween_finished():
	is_moving = false
	grid_position = position / cell_size
	current_direction = Vector3.ZERO

func is_position_valid(pos: Vector3) -> bool:
	return pos in global_cell_coordinates

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
