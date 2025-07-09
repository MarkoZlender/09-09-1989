class_name GameController extends Node

signal scene_loaded
signal load_progress(percent: float)

@export var world_3d: Node3D
@export var world_2d: Node2D
@export var gui: Control
@export var transition_controller: TransitionController
#@export_file("*.tscn") var start_scene: String = "res://scenes/ui/main_menu.tscn"
@export var start_scene: PackedScene

var current_3d_scene: Node3D
var current_2d_scene: Node2D
var current_gui_scene: Control

var process_scene_params: Array = []

# spawn point in the next scene
var next_position_marker: String = ""

var new_3d_scene: Node3D

func _ready() -> void:
	Global.game_controller = self

	Global.signal_bus.level_changed.connect(_on_level_changed)
	Global.signal_bus.player_died.connect(_on_player_died)
	Global.signal_bus.quest_completed.connect(_on_quest_completed)
	Global.signal_bus.final_dialogue_completed.connect(_on_final_dialogue_completed)
	set_process(false)

	if start_scene.resource_path.find("res://scenes/ui") == -1:
		change_3d_scene(start_scene.resource_path)
	else:
		change_gui_scene(start_scene.resource_path, false, false, false)

func _process(_delta: float) -> void:
	if process_scene_params.size() == 0:
		return
	_deferred_load_scene_threaded(process_scene_params[0])
	# change_3d_scene(
	# 	process_scene_params[0],
	# 	process_scene_params[1],
	# 	process_scene_params[2],
	# 	process_scene_params[3],
	# 	process_scene_params[4],
	# 	process_scene_params[5],
	# 	process_scene_params[6]
	# )
	#print("loading")

func change_gui_scene(
		new_scene: String,
		delete: bool = true,
		keep_running: bool = false,
		transition: bool = true,
		transition_in: String = "fade_in",
		transition_out: String = "fade_out",
		seconds: float = 1.0
	) -> void:
	transition_controller.show()
	if transition:
		transition_controller.transition(transition_out, seconds)
		await transition_controller.animation_player.animation_finished

	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free() # Removes node entirely
		elif keep_running:
			current_gui_scene.visible = false # Keeps node in memory and running
		else:
			gui.remove_child(current_gui_scene) # Keeps node in memory, does not run

	if new_scene != "":
		var new: Node = load(new_scene).instantiate()
		gui.add_child(new)
		gui.move_child(new, 0)
		current_gui_scene = new
		if transition:
			transition_controller.transition(transition_in, seconds)
			await transition_controller.animation_player.animation_finished
		transition_controller.hide()
	else:
		if transition:
			transition_controller.transition(transition_in, seconds)
			await transition_controller.animation_player.animation_finished
		transition_controller.hide()
		return

# same as change_2d_scene, but for 3D scenes
func change_3d_scene(
		new_scene: String,
		delete: bool = true,
		keep_running: bool = false,
		transition: bool = true,
		transition_in: String = "fade_in",
		transition_out: String = "fade_out",
		seconds: float = 1.0
	) -> void:
	
	if is_processing():
		return
	else:
		process_scene_params = [
			new_scene,
			delete,
			keep_running,
			transition,
			transition_in,
			transition_out,
			seconds
		]
		set_process(true)
	if new_scene == "":
		current_3d_scene.queue_free()
		return

	change_gui_scene(Global.LOADING_SCREEN, true, false, true)

	#await get_tree().process_frame
	if transition:
		transition_controller.transition(transition_out, seconds)
		await transition_controller.animation_player.animation_finished

	if current_3d_scene != null:
		if delete:
			current_3d_scene.queue_free() # Removes node entirely
		elif keep_running:
			current_3d_scene.visible = false # Keeps node in memory and running
		else:
			world_3d.remove_child(current_3d_scene) # Keeps node in memory, does not run


	#_load_scene_threaded(new_scene)
	ResourceLoader.load_threaded_request(new_scene, "PackedScene", false, ResourceLoader.CacheMode.CACHE_MODE_REUSE)
	_deferred_load_scene_threaded(new_scene)

	
	#await scene_loaded
	#await scene_loaded
	
	# var new: Resource = ResourceLoader.load_threaded_get(new_scene)
	# var instance: Node = new.instantiate()
	# world_3d.add_child(instance)
	# current_3d_scene = instance
	#transition_controller.transition(transition_in, seconds)
	#await transition_controller.animation_player.animation_finished
	#await scene_loaded
	#change_gui_scene("", true, false, true)

func _deferred_load_scene_threaded(scene_path: String) -> void:
	var progress: Array = []
	
	#while true:
	var status: int = ResourceLoader.load_threaded_get_status(scene_path, progress)
	load_progress.emit(floor(progress[0] * 100))
	#print(str(floor(progress[0] * 100)) + "%")
	#print("Status: " + str(status))
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		#print(str(floor(progress[0] * 100)) + "%")
		load_progress.emit(floor(progress[0] * 100))
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		# Resource is loaded, we can use it
		var new: Resource = ResourceLoader.load_threaded_get(scene_path)
		var instance: Node = new.instantiate()

		#await idle frame
		#await get_tree().process_frame
		#await instance.ready # Ensure the instance is ready before adding it to the scene tree
		#call_deferred("print", "instantiated: " + instance.name)
		#world_3d.call_deferred("add_child", instance)
		if is_instance_valid(instance):
			print("Instance is valid: " + instance.name)
			world_3d.call_deferred("add_child", instance)
		#print("added to world_3d: " + instance.name)
			current_3d_scene = instance
			scene_loaded.emit()
			set_process(false)
			change_gui_scene("", true, false, true)
		else:
			printerr("Instance is not valid: " + scene_path)
	#await get_tree().create_timer(0.001).timeout
	#await Engine.get_main_loop().process_frame

func change_2d_scene(
		new_scene: String,
		delete: bool = true,
		keep_running: bool = false,
		transition: bool = true,
		transition_in: String = "fade_in",
		transition_out: String = "fade_out",
		seconds: float = 1.0
	) -> void:

	if transition:
		transition_controller.transition(transition_out, seconds)
		await transition_controller.animation_player.animation_finished

	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free() # Removes node entirely
		elif keep_running:
			current_2d_scene.visible = false # Keeps node in memory and running
		else:
			world_2d.remove_child(current_2d_scene) # Keeps node in memory, does not run
	var new: Node = load(new_scene).instantiate()
	world_2d.add_child(new)
	current_2d_scene = new
	transition_controller.transition(transition_in, seconds)

func _on_level_changed() -> void:
	for node: Node in gui.get_children():
		if node.name != "TransitionController":
			node.queue_free()

func _on_player_died() -> void:
	change_gui_scene(Global.GAME_OVER_SCENE, true, false, true)

func _play_transition(play_half: bool, stop_half: bool) -> void:
	%GrayBackground.visible = true
	var tween: Tween = create_tween()
	tween.tween_property(%GrayBackground, "color:a", 1.0, 1.0)
	await tween.finished
	await Global.wait(5.0)
	if !stop_half:
		if play_half:
			await Global.wait(2.0)
			%GrayBackground.color.a = 0.0
		else:
			Global.signal_bus.clear_to_remove.emit()
			tween = create_tween()
			tween.tween_property(%GrayBackground, "color:a", 0.0, 1.0)
			await tween.finished

func _on_quest_completed() -> void:
	await _play_transition(false, false)

func _on_final_dialogue_completed() -> void:
	await _play_transition(true, false)
	#await Global.wait(0.1)
	Global.signal_bus.play_news.emit()

