extends Node3D

@onready var velocity: Vector3 = Vector3.ZERO
@onready var attack_state: bool = false
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var is_moving_backwards: bool = false
@onready var is_hurt:bool = false
@onready var is_interacting: bool = false

@onready var flashlight: Light3D = %Flashlight
@onready var flashlight_model: Node3D = %FlashlightModel
@onready var turn_input: float = 0.0

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("attack") && !is_interacting && !is_hurt:
		animation_player.get_animation("attack").loop_mode = Animation.LOOP_LINEAR
		attack_state = true

	elif Input.is_action_just_released("attack") && !is_interacting && !is_hurt:
		animation_player.get_animation("attack").loop_mode = Animation.LOOP_NONE
		attack_state = false
	
	elif is_hurt:
		animation_player.get_animation("attack").loop_mode = Animation.LOOP_NONE
		attack_state = false
	
	if event.is_action_pressed("flashlight") && !is_interacting:
		flashlight.visible = !flashlight.visible
		flashlight_model.get_node("FlashlightEmission").visible = !flashlight_model.get_node("FlashlightEmission").visible
		flashlight_model.get_node("FlashlightMesh").mesh.surface_get_material(0).emission_enabled = flashlight.visible
		%FlashlightAudioStreamPlayer.play()

func _physics_process(_delta: float) -> void:
	velocity = owner.velocity
	is_moving_backwards = owner.is_moving_backwards
	is_hurt = owner.is_hurt
	turn_input = owner.turn_input
	is_interacting = owner.is_interacting