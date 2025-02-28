class_name GameController extends Node

signal scene_loaded
signal load_progress(percent: String)

@export var world_3d: Node3D
@export var world_2d: Node2D
@export var gui: Control
@export var transition_controller: TransitionController
@export_file("*.tscn") var start_scene: String = "res://scenes/ui/main_menu.tscn"

var current_3d_scene: Node3D
var current_2d_scene: Node2D
var current_gui_scene: Control

func _ready() -> void:
	Global.game_controller = self
	#%InventoryItemList.inventory = Global.inventory
	#%CtrlInventory.inventory = Global.inventory
	#%CtrlInventory.grab_focus()
	# check if start scene is in res://scenes/ui or not and change scene accordingly
	if start_scene.find("res://scenes/ui") == -1:
		change_3d_scene(start_scene)
	else:
		change_gui_scene(start_scene, false, false, false)

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

	change_gui_scene(Global.LOADING_SCREEN, true, false, true)
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
	# change scene to loading screen, delete previous ui scene, don't keep running, don't transition

	_load_scene_threaded(new_scene)
	await scene_loaded
	var new: Resource = ResourceLoader.load_threaded_get(new_scene)
	var instance: Node = new.instantiate()
	world_3d.add_child(instance)
	current_3d_scene = instance
	transition_controller.transition(transition_in, seconds)
	await transition_controller.animation_player.animation_finished
	change_gui_scene("", true, false, true)

func _load_scene_threaded(scene_path: String) -> void:
	call_deferred("_deferred_load_scene_threaded", scene_path)

func _deferred_load_scene_threaded(scene_path: String) -> void:
	var progress: Array = []
	ResourceLoader.load_threaded_request(scene_path)
	while true:
		var status: int = ResourceLoader.load_threaded_get_status(scene_path, progress)
		print(str(floor(progress[0] * 100)) + "%")
		load_progress.emit(str(floor(progress[0] * 100)) + "%")
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			break
		await get_tree().create_timer(0.001).timeout
		#await Engine.get_main_loop().process_frame
	scene_loaded.emit()

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
