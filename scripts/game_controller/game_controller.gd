class_name GameController extends Node

signal scene_loaded

@export var world_3d: Node3D
@export var world_2d: Node2D
@export var gui: Control
@export var transition_controller: TransitionController

const _loading_screen: String = "res://scenes/ui/loading_screen.tscn"

var current_3d_scene
var current_2d_scene
var current_gui_scene

var new_3d_scene

func _ready() -> void:
	set_process(false)
	Global.game_controller = self
	change_gui_scene("res://scenes/ui/main_menu.tscn", false, false, false)

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
		var new = load(new_scene).instantiate()
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
	# empty transition in to new scene
	change_gui_scene("", true, false, true)
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
	change_gui_scene(_loading_screen, true, false, false)
	new_3d_scene = new_scene
	set_process(true)
	ResourceLoader.load_threaded_request(new_scene, "", true)
	await scene_loaded
	set_process(false)
	var new = ResourceLoader.load_threaded_get(new_scene)
	var instance = new.instantiate()
	world_3d.add_child(instance)
	current_3d_scene = instance
	transition_controller.transition(transition_in, seconds)
	await transition_controller.animation_player.animation_finished
	change_gui_scene("", true, false, true)

func _load_scene_threaded(scene_path: String) -> void:
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	print(str(floor(progress[0] * 100)) + "%")
	if status == ResourceLoader.THREAD_LOAD_LOADED:
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
	var new = load(new_scene).instantiate()
	world_2d.add_child(new)
	current_2d_scene = new
	transition_controller.transition(transition_in, seconds)

func _process(_delta: float) -> void:
	_load_scene_threaded(new_3d_scene)