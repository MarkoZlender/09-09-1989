class_name InteractionManager extends Node
# https://www.youtube.com/watch?v=ajCraxGAeYU

var active_areas: Array[InteractComponent] = []
var can_interact: bool = true

@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	Global.interaction_manager = self

func _physics_process(_delta: float) -> void:
	if active_areas.size() > 0 && can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && can_interact:
		if active_areas.size() > 0:
			can_interact = false
			await active_areas[0].interact.call()
			can_interact = true

func register_area(area: InteractComponent) -> void:
	active_areas.push_back(area)

func unregister_area(area: InteractComponent) -> void:
	active_areas.erase(area)

func _sort_by_distance_to_player(area1: InteractComponent, area2: InteractComponent) -> bool:
	var area1_distance: float = player.global_position.distance_to(area1.global_position)
	var area2_distance: float = player.global_position.distance_to(area2.global_position)
	return area1_distance < area2_distance
