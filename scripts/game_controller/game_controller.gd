class_name GameController extends Node

signal scene_loaded
signal load_progress(percent: float)

@export var world_3d: Node3D
@export var gui: Control
@export var transition_controller: TransitionController
@export var start_scene: PackedScene

var current_3d_scene: Node3D
var current_gui_scene: Control

var new_scene_path: String

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
	if new_scene_path == "":
		return
	_load_scene_async(new_scene_path)

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
		new_scene_path = new_scene
		set_process(true)
	if new_scene == "":
		set_process(false)
		current_3d_scene.queue_free()
		return

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

	ResourceLoader.load_threaded_request(new_scene, "PackedScene", false, ResourceLoader.CacheMode.CACHE_MODE_IGNORE_DEEP)
	_load_scene_async(new_scene)

func _load_scene_async(scene_path: String) -> void:
	var progress: Array = []
	var status: int = ResourceLoader.load_threaded_get_status(scene_path, progress)
	load_progress.emit(floor(progress[0] * 100))
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		load_progress.emit(floor(progress[0] * 100))
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var new: Resource = ResourceLoader.load_threaded_get(scene_path)
		var instance: Node = new.instantiate()
		world_3d.call_deferred("add_child", instance)
		current_3d_scene = instance
		scene_loaded.emit()
		set_process(false)
		change_gui_scene("", true, false, true)

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
	Global.signal_bus.play_news.emit()
