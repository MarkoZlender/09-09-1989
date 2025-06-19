extends Node3D

@onready var velocity: Vector3 = Vector3.ZERO
@onready var attack_state: bool = false
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var is_moving_backwards: bool = false
@onready var is_hurt:bool = false
@onready var flashlight: Light3D = %Flashlight
@onready var flashlight_model: Node3D = %FlashlightModel

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		animation_player.get_animation("attack").loop_mode = Animation.LOOP_LINEAR
		attack_state = true

	elif event.is_action_released("attack"):
		animation_player.get_animation("attack").loop_mode = Animation.LOOP_NONE
		attack_state = false
	
	if event.is_action_pressed("flashlight"):
		flashlight.visible = !flashlight.visible
		flashlight_model.get_node("FlashlightEmission").visible = !flashlight_model.get_node("FlashlightEmission").visible
		flashlight_model.get_node("FlashlightMesh").mesh.surface_get_material(0).emission_enabled = flashlight.visible

func _physics_process(_delta: float) -> void:
	velocity = owner.velocity
	is_moving_backwards = owner.is_moving_backwards
	is_hurt = owner.is_hurt
