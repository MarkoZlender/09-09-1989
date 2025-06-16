class_name Player
extends CharacterBody3D

#region Constants

const JUMP_VELOCITY: float = 3.5

#endregion

#region Exports

@export var player_data: PlayerData

#endregion

#region Variables

var is_moving: bool = false
var is_attacking: bool = false
var is_moving_backwards: bool = false
var is_hurt:bool = false
var is_interacting: bool = false


var direction: Vector3 = Vector3.ZERO
var last_facing_direction: Vector2 = Vector2(0, -1)
var camera_velocity: Vector3 = Vector3.ZERO

var knockback_direction: Vector3 = Vector3.ZERO
var knockback_strength: float = 2.0  # Adjust the force as needed
var knockback_duration: float = 0.2  # How long the knockback lasts
var knockback_timer: float = 0.0
var turn_speed: float = 2.0  # Adjust the turning speed as needed

#endregion

#region Onready variables

@onready var sfx_player: AudioStreamPlayer3D = $SFXPlayer
@onready var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")
@onready var player_model: Node3D = $PlayerModel

#endregion

#region Built-in functions

func _ready() -> void:
	#$HurtSurfaceArea.connect("area_entered", _on_hurt)
	#$HurtSurfaceArea.connect("area_exited", _on_disengage)
	Global.signal_bus.enemy_died.connect(_on_enemy_defeated)
	Global.signal_bus.item_collected.connect(_on_item_collected)
	Global.signal_bus.player_died.connect(_on_player_died)
	Global.signal_bus.interaction_started.connect(_on_player_interacted)
	Global.signal_bus.interaction_ended.connect(_on_player_ended_interaction)
	
	player_model.get_node("AnimationTree").connect("animation_finished", _on_attack_animation_finished)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if Global.game_controller.get_node_or_null("GUI/InventoryItemList") == null:
			_add_inventory()
		else:
			Global.game_controller.get_node("GUI/InventoryItemList").queue_free()
	
	if event.is_action_pressed("attack"):
		is_attacking = true

#endregion

#region Public functions

func move(delta: float) -> void:
	#if !is_attacking:
	_play_footsteps()

	# Tank controls input
	var turn_input: float= Input.get_action_strength("right") - Input.get_action_strength("left")
	var move_input: float= Input.get_action_strength("up") - Input.get_action_strength("down")

	if move_input != 0:
		is_moving = true
	else:
		is_moving = false

	# Rotate player (Y axis)
	rotation.y -= turn_input * turn_speed * delta

	# Determine if moving backwards
	is_moving_backwards = move_input < 0

	# Limit speed if moving backwards
	var speed: float= player_data.speed

	if is_moving_backwards:
		is_moving_backwards = true
		speed *= 0.3  # Limit backward speed to 50%
	else:
		is_moving_backwards = false

	# Move forward/backward in local space
	var forward: Vector3= -transform.basis.z.normalized()
	velocity.x = forward.x * move_input * speed
	velocity.z = forward.z * move_input * speed

	move_and_slide()

	if is_hurt:
		print("Hurting player")

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

#endregion

#region Private functions 

func _play_footsteps() -> void:
	if is_moving && is_on_floor():
		if not sfx_player.playing && $Timer.time_left <= 0:
			sfx_player.stream = player_data.walk_sfx
			sfx_player.pitch_scale = 1.0 + randf_range(-0.1, 0.1)
			sfx_player.play()
			$Timer.start(player_data.footstep_timer)
	else:
		sfx_player.pitch_scale = 1.0
		sfx_player.volume_db = 0

func _apply_knockback(area: Area3D) -> void:
	knockback_timer = knockback_duration
	knockback_direction = (global_position - area.global_position).normalized()
	Global.signal_bus.player_hurt.emit(player_data.health)

func _add_inventory() -> void:
	var loaded_resource: Resource = load("res://scenes/ui/inventory/inventory_item_list.tscn")
	var instance: Node = loaded_resource.instantiate()
	Global.game_controller.get_node("GUI").add_child(instance)
	Global.game_controller.get_node("GUI").move_child(instance, 0)

func _check_level() -> void:
	if player_data.experience >= player_data.level_progression[player_data.level-1]:
		player_data.level += 1
		print("Level up! New level: ", player_data.level)

#endregion

#region Signal callables

func _on_hurt(area: Area3D) -> void:
	if area is EnemyAttackSurfaceArea:
		is_hurt = true
		player_data.health -= area.get_parent().enemy_data.hit_strength
		Global.signal_bus.spawn_blood.emit(global_position)
		if player_data.health <= 0:
			Global.signal_bus.player_died.emit()
		_apply_knockback(area)

func _on_disengage(area: Area3D) -> void:
	if area is EnemyAttackSurfaceArea:
		is_hurt = false

func _on_enemy_defeated(enemy: Enemy) -> void:
	player_data.experience += enemy.enemy_data.experience
	_check_level()

func _on_item_collected(item: Collectible) -> void:
	if item is Coin:
		player_data.coins += 1
		print("Coins: ", player_data.coins)

func _on_player_died() -> void:
	get_tree().paused = true

func _on_attack_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hurt":
		is_hurt = false

	if anim_name == "attack":
		is_attacking = false

func _on_player_interacted() -> void:
	is_interacting = true

func _on_player_ended_interaction() -> void:
	is_interacting = false

func _on_player_hurt_box_area_entered(area:Area3D) -> void:
	pass
	# if area is EnemyHitBox:
	# 	if player_data.health <= 0:
	# 		Global.signal_bus.player_died.emit()
	# 		return
	# 	player_data.health -= area.get_parent().enemy_data.hit_strength
	# 	is_hurt = true

#endregion
