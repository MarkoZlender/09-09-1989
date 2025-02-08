extends Node2D

@export var tile_size: Vector2 = Vector2(16, 16)
@export var tilemap: TileMapLayer
@onready var timer: Timer = $Timer

enum ROTATION_DIRECTION {
	LEFT,
	RIGHT
}

var tilemap_position: Vector2 = Vector2(2, 2)
var global_tilemap_coordinates: Array[Vector2] = []

var is_moving: bool= false
var inputs: Dictionary = {
	"move_right": Vector2.RIGHT,
	"move_left": Vector2.LEFT,
	"move_forward": Vector2.UP,
	"move_back": Vector2.DOWN
}

func _ready() -> void:
	#self.global_transform.origin = gridmap.map_to_local(Vector3i(0, 1, 0))
	global_position = tilemap.map_to_local(tilemap_position)
	for tile: Vector2i in tilemap.get_used_cells():
		global_tilemap_coordinates.append(tilemap.map_to_local(tile))

func _process(delta: float) -> void:
	handle_movement_input()


func handle_movement_input() -> void:
	var local_forward: Vector2 = -transform.y
	var local_back: Vector2 = transform.y
	var local_left: Vector2 = transform.x
	var local_right: Vector2 = -transform.x

#region forward_back
	# not using switch/match because it is slower in gdscript than if-elif-else statements
	if Input.is_action_pressed("move_forward") && is_position_valid(position + local_forward * tile_size) && timer.is_stopped():
		move(local_forward)
		timer.start(0.2)

	elif Input.is_action_pressed("move_back") && is_position_valid(position + local_back * tile_size) && timer.is_stopped():
		move(local_back)
		timer.start(0.2)
#endregion

#region strafing
	elif Input.is_action_pressed("strafe_left") && is_position_valid(position + local_left * tile_size) && timer.is_stopped():
			move(local_left)
			timer.start(0.2)

	elif Input.is_action_pressed("strafe_right") && is_position_valid(position + local_right * tile_size) && timer.is_stopped():
			move(local_right)
			timer.start(0.2)
#endregion

#region left_right
	elif Input.is_action_pressed("move_left") && !Input.is_action_pressed("strafe_left") && timer.is_stopped():
		rotate_player(ROTATION_DIRECTION.LEFT)
		timer.start(0.2)

	elif Input.is_action_pressed("move_right") && !Input.is_action_pressed("strafe_right") && timer.is_stopped():
		rotate_player(ROTATION_DIRECTION.RIGHT)
		timer.start(0.2)

	else:
		is_moving = false

func move(direction: Vector2) -> void:
	is_moving = true
	position = position + direction * tile_size
	#play_footsteps()

func rotate_player(direction: ROTATION_DIRECTION) -> void:
	is_moving = true
	
	if direction == ROTATION_DIRECTION.LEFT:
		transform = transform.rotated_local(-PI / 2)
	elif direction == ROTATION_DIRECTION.RIGHT:
		transform = transform.rotated_local(PI / 2)

func is_position_valid(pos: Vector2) -> bool:
	var tile: Vector2i = tilemap.local_to_map(pos)
	return tilemap.get_cell_tile_data(tile) != null
