extends Node3D

@export var min_max_interpolation = Vector2(0.0, 0.9)
@export var foot_height_offset = 0.05

@onready var target_l: Marker3D = $Target_l
@onready var target_r: Marker3D = $Target_r
@onready var raycast_left: RayCast3D = $RayCast_left
@onready var raycast_right: RayCast3D = $RayCast_right
@onready var ik_right: SkeletonIK3D = $Cynthia_002/Skeleton3D/SkeletonIK3D_right
@onready var ik_left: SkeletonIK3D = $Cynthia_002/Skeleton3D/SkeletonIK3D_left
@onready var no_raycast_target_l: Marker3D = $no_raycast_target_l
@onready var no_raycast_target_r: Marker3D = $no_raycast_target_r

func _ready():
	ik_left.start()
	ik_right.start()

func update_ik_target_pos(target, raycast, no_raycast_pos, _foot_height_offset):
	if raycast.is_colliding():
		var hit_point = raycast.get_collision_point().y + _foot_height_offset
		target.global_transform.origin.y = hit_point
	else:
		target.global_transform.origin.y = no_raycast_pos.global_transform.origin.y

func _physics_process(delta: float) -> void:
	update_ik_target_pos(target_l, raycast_left, no_raycast_target_l, foot_height_offset)
	update_ik_target_pos(target_r, raycast_right, no_raycast_target_r, foot_height_offset)