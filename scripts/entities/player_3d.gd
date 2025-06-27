class_name Player
extends CharacterBody3D

#region Exports

@export var player_data: PlayerData

#endregion

#region Variables
var current_state: PlayerState.State = PlayerState.State.IDLE

var direction: Vector3 = Vector3.ZERO
var turn_speed: float = 2.0  # Adjust the turning speed as needed
var max_speed: float = 10.0  # Adjust the maximum speed as needed
var acceleration: float = 20.0
var turn_input: float = 0.0
var move_input: float = 0.0

#endregion

#region Onready variables

@onready var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")
@onready var player_model: Node3D = $PlayerModel
@onready var player_model_anim_player: AnimationPlayer = player_model.get_node("AnimationPlayer")

#endregion

#region Built-in functions

func _ready() -> void:
	Global.signal_bus.item_rigid_body_collected.connect(_on_item_rigid_body_collected)
	Global.signal_bus.player_died.connect(_on_player_died)
	Global.signal_bus.player_interacting.connect(_on_player_interacted)
	
	player_model.get_node("AnimationTree").connect("animation_finished", _on_animation_finished)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if Global.game_controller.get_node_or_null("GUI/InventoryItemList") == null:
			_add_inventory()
		else:
			Global.game_controller.get_node("GUI/InventoryItemList").queue_free()
	
	if Input.is_action_just_pressed("attack") && current_state != PlayerState.State.HURT && current_state != PlayerState.State.INTERACTING:
		current_state = PlayerState.State.ATTACKING
	# 	player_model.get_node("AnimationPlayer").get_animation("attack").loop_mode = Animation.LOOP_LINEAR
	# elif event.is_action_released("attack"):
	# 	player_model.get_node("AnimationPlayer").get_animation("attack").loop_mode = Animation.LOOP_NONE

#endregion

#region Public functions

func move(delta: float) -> void:
	# Tank controls input
	turn_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_input = Input.get_action_strength("up") - Input.get_action_strength("down")
	
	var speed: float = player_data.speed
	print("move input: ", move_input)

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

	# Rotate player (Y axis)
	rotation.y -= turn_input * turn_speed * delta

	# Limit speed if moving backwards
	

	# if move_input < 0 && current_state != PlayerState.State.HURT && current_state != PlayerState.State.ATTACKING:
	# 	current_state = PlayerState.State.MOVING_BACKWARDS
	# 	speed *= 0.3  # limit backward speed to 50%

	# Move forward/backward in local space
	var forward: Vector3= -transform.basis.z.normalized()
	velocity.x = forward.x * move_input * speed
	velocity.z = forward.z * move_input * speed
	_apply_gravity(delta)
	#print("Velocity: ", velocity)
	move_and_slide()

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


func _apply_knockback(area: Area3D) -> void:
	Global.signal_bus.player_hurt.emit(player_data.health)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	else:
		velocity.y = 0.0

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

# func _on_item_collected(item: Collectible) -> void:
# 	if item is Coin:
# 		player_data.coins += 1
# 		print("Coins: ", player_data.coins)

func _on_item_rigid_body_collected(item: CollectibleRigidBody3D) -> void:
	if item is Tooth:
		player_data.teeth += 1
		print("Teeth: ", player_data.teeth)

func _on_player_died() -> void:
	get_tree().paused = true

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hurt":
		current_state = PlayerState.State.IDLE

	if anim_name == "attack":
		current_state = PlayerState.State.IDLE

func _on_player_interacted(state: bool) -> void:
	if state == true:
		current_state = PlayerState.State.INTERACTING
	else:
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
