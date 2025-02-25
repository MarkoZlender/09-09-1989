extends Node3D

@onready var scene: SpotLight3D
@export var instance_count: int = 10000
@export var instance_count2: int = 10000

func _ready():
	for i in range(instance_count):
		var obj = SpotLight3D.new()
		obj.light_energy = 13.0
		obj.position = Vector3(randf_range(-100, 100), 0, randf_range(-100, 100))
		add_child(obj)
	
	for i in range(instance_count2):
		var obj2 = CSGBox3D.new()
		obj2.use_collision = true
		obj2.size = Vector3(10, 1, 10)
		obj2.position = Vector3(randf_range(-1000, 1000), randf_range(0, 5), randf_range(-1000, 1000))
		add_child(obj2)
