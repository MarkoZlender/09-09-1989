extends Node3D

var current_state: PlayerState.State = PlayerState.State.IDLE

@onready var velocity: Vector3 = Vector3.ZERO
@onready var attack_state: bool = false
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var flashlight: Light3D = %Flashlight
@onready var flashlight_model: Node3D = %FlashlightModel
@onready var turn_input: float = 0.0
@onready var idle_frame_count: int = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight") && current_state != PlayerState.State.INTERACTING:
		flashlight.visible = !flashlight.visible
		flashlight_model.get_node("FlashlightEmission").visible = !flashlight_model.get_node("FlashlightEmission").visible
		flashlight_model.get_node("FlashlightMesh").mesh.surface_get_material(0).emission_enabled = flashlight.visible
		%FlashlightAudioStreamPlayer.play()

func _physics_process(_delta: float) -> void:
	current_state = owner.current_state
	velocity = owner.velocity
	turn_input = owner.turn_input
	idle_frame_count = owner.idle_frame_count
