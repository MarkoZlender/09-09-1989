class_name Player
extends CharacterBody3D

#region Exports

@export var player_data: PlayerData

#endregion

#region Variables
var current_state: PlayerState.State = PlayerState.State.IDLE

var direction: Vector3 = Vector3.ZERO
var turn_speed: float = 2.0
var max_speed: float = 10.0
var acceleration: float = 20.0
var turn_input: float = 0.0
var move_input: float = 0.0
var idle_frame_count: int = 0

#endregion

#region Onready variables

@onready var player_model: Node3D = $PlayerModel
@onready var player_model_anim_player: AnimationPlayer = player_model.get_node("AnimationPlayer")

#endregion

#region Built-in functions

func _ready() -> void:
	Global.signal_bus.player_died.connect(_on_player_died)
	Global.signal_bus.player_interacting.connect(_on_player_interacted)
	
	player_model.get_node("AnimationTree").connect("animation_finished", _on_animation_finished)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("attack") && current_state != PlayerState.State.HURT \
	&& current_state != PlayerState.State.INTERACTING:
		current_state = PlayerState.State.ATTACKING

#endregion

#region Public functions

func move(delta: float) -> void:
	# Tank controls input
	turn_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_input = Input.get_action_strength("up") - Input.get_action_strength("down")
	
	if move_input == 0:
		idle_frame_count += 1
	else:
		idle_frame_count = 0

	var speed: float = player_data.speed

	if current_state != PlayerState.State.ATTACKING \
	&& current_state != PlayerState.State.HURT \
	&& current_state != PlayerState.State.INTERACTING:
		if move_input < 0:
			current_state = PlayerState.State.MOVING_BACKWARDS
			speed *= 0.3
		elif move_input != 0:
			current_state = PlayerState.State.MOVING
		elif move_input == 0:
			current_state = PlayerState.State.IDLE

	# Rotate player on Y axis
	rotation.y -= turn_input * turn_speed * delta

	# Move forward/backward in local space
	var forward: Vector3= -transform.basis.z.normalized()
	velocity.x = forward.x * move_input * speed
	velocity.z = forward.z * move_input * speed
	
	_apply_gravity(delta)
	move_and_slide()

#endregion

#region Private functions 

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	else:
		velocity.y = 0.0

#endregion

#region Signal callables

func _on_player_died() -> void:
	get_tree().paused = true

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hurt" && current_state == PlayerState.State.INTERACTING:
		current_state = PlayerState.State.INTERACTING
	elif anim_name == "hurt":
		current_state = PlayerState.State.IDLE

	if anim_name == "attack" && current_state == PlayerState.State.INTERACTING:
		current_state = PlayerState.State.INTERACTING
	elif anim_name == "attack":
		current_state = PlayerState.State.IDLE

func _on_player_interacted(state: bool) -> void:
	if state == true:
		current_state = PlayerState.State.INTERACTING
	elif state == false:
		current_state = PlayerState.State.IDLE

func _on_player_hurt_box_area_entered(area:Area3D) -> void:
	if area is EnemyHitBox:
		# leave this print here, hitbox works better with it for some reason
		print("Player hurt by enemy hitbox")
		player_data.health -= area.get_parent().get_parent().get_parent().get_parent().get_parent().enemy_data.hit_strength
		Global.signal_bus.player_hurt.emit(player_data.health)
		Global.signal_bus.spawn_blood.emit(global_position)
		if player_data.health <= 0:
			Global.signal_bus.player_died.emit()
			current_state = PlayerState.State.DEAD
			return
		current_state = PlayerState.State.HURT
		#is_attacking = false

#endregion
